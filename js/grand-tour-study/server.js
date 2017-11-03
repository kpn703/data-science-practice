/**
 *  Description:
 *      Scrape data as defined in the readme from http://uci.ch/road/results/
 *
 *  At the time of writing, uci website has jQuery
 **/

'use strict';

const Bluebird = require('bluebird'); // required twice so I can sometimes be explicit
const cheerio = require('cheerio');
const fs = Bluebird.promisifyAll(require('fs'));
const Promise = require('bluebird');
const puppeteer = require('puppeteer');
const utils = require('./utils.js');

const iChunkSize = 30;
const iThrottleInterval = 2; // seconds between batch of requests
const sRootUrl = 'https://dataride.uci.ch/iframe/results/10';
const sResultDir = __dirname + '/results';

const iFirstSeason = 2009;
const iLastSeason = 2017;
const arrsRaceSubstrings = ['Giro', 'Italia', 'Tour de France', 'Vuelta', 'Espa']; // TODO: not restrictive enough

let wsMain;
let wsErrorLog;

let browser;
let iCurrentBatch = 1;

var arroRenames = [];
var arroSubtopics = [];
var arroErrors = [];

const arrMockBatches = [
                        [],
                        [],
                        []
                        ];

main();

async function fpoGetRenameData(_oRename) {
    let loggerMessage;

    // get csv or log as missing

    loggerMessage = _oRename.id + ', true, successfully got at least some data'
    _oRename.loggerMessage = loggerMessage;
    utils.fStandardWriter(_oRename, wsRenames);
    return Promise.resolve(loggerMessage);
}

//  _arr is an array of Renames
//  Promise.reflect() ref: http://bluebirdjs.com/docs/api/reflect.html
//  _oRename is a reflected Rename promise result.
//  Be sure you know what that means before messing with it.
async function fpCollectBatchInformation(_arr) {
    let arrBatchResult = await utils.settleAll(_arr, fpoGetRenameData);
    return arrBatchResult;
}

// TODO: maybe not needed
async function fGetDataByUrl(sUrl) {
    const page = await browser.newPage();
    let _$;

    await page.goto(sUrl);
    _$ = cheerio.load(await page.content());

    page.close()
    return _$('pre').text();
}

// returns a page which has been navigated to the specified season page
// note: this whole fucking method is a hack
// not generalizable or temporally reliable in case of a site refactor
// target site includes jQuery already. _$ is cheerio, $ is jQuery
async function fpGetSeasonPage(sUrl, iSeason) {
    const _page = await browser.newPage();
    let executionContext;
    let _$;

    await _page.goto(sUrl);
    _$ = cheerio.load(await _page.content());

    executionContext = _page.mainFrame().executionContext();
    await executionContext.evaluate((iSeason) => {
        $('.uci-main-content .k-dropdown').last().click();     // open the seasons dropdown
        $('#seasons_listbox li').filter(function(){            // click the particular season
            return this.textContent === String(iSeason);
        })
        .click();

        // maybe wait some amount of time here to ensure page loads data...2 seconds?
        // eg; timeout, Promise.resolve(8 * 7)
    });

    return _page;
    //page.close();
}

// get each season page in parallel
// traverse each page under the season in parallel (~21)
// find strings of interest. open those pages. it's designed as SPA; may need to open new window
// if using a new window, url looks like https://dataride.uci.ch/iframe/CompetitionResults/46187?disciplineId=10
// for strings of interest, get general classification, points classification, and stage classification for each stage
// these are a bunch of csvs; maybe download instead of write file (actually, that's equivalent)
async function main() {
    let arrpageSeasons = [];
    let i;
    let _oPage;

    browser = await puppeteer.launch();

    if (!fs.existsSync(sResultDir)) {
        fs.mkdirSync(sResultDir);
    }

    fSetWriters();

    // get an array of browser pages; one for each season
    for (i = iFirstSeason; i < iLastSeason; i++) {
        _oPage = fpGetSeasonPage(sRootUrl, i);
        arrpageSeasons.push(_oPage);
    }

    await utils.settleAll(arrpageSeasons, function(pPage){
        return pPage;
    });

    //sanity check...it should be a list of puppeteer browser pages
    console.log(arrpageSeasons);

    /*
    await utils.forEachThrottledAsync(iThrottleInterval, arrBatches, function (_arrBatch) {
        console.log('batch process for batch # ' + (iCurrentBatch++) + ' of ' + arrBatches.length)
        return fpCollectBatchInformation(_arrBatch);
    });

    let arrBatches = utils.chunk(arroRenames, iChunkSize);
    //console.log('batch check: ' + arrBatches.length, arrBatches[0])
    //arrBatches = [arrBatches.pop(),[]];// testing with a subset
    //let arrBatches = arrMockBatches;

    await utils.forEachThrottledAsync(iThrottleInterval, arrBatches, function (_arrBatch) {
        console.log('batch process for batch # ' + (iCurrentBatch++) + ' of ' + arrBatches.length)
        return fpCollectBatchInformation(_arrBatch);
    });
    */

    browser.close();
    process.exit();
}

// returns true when a string has content after rendering.
// returns false on invalid html. For example '</p>' is just a closing tag and will return false.
function fRenderableContent(sCandidateHtml) {
    let bValidEnough = false;

    try {
        bValidEnough = cheerio.load(sCandidateHtml).text().trim().length > 0;
    } catch (e) {}

    return bValidEnough;
}

//  must ensure path exists before setting writers
function fSetWriters() {
    wsMain = fs.createWriteStream(sResultDir + '/main.txt'); // TODO: can it be a const?
    wsErrorLog = fs.createWriteStream(sResultDir + '/errors.txt'); // TODO: can it be a const?
}