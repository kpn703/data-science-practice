//ref: https://coderwall.com/p/ohjerg/read-large-text-files-in-nodejs
const fs = require('fs');
const readline = require('readline');
const Stream = require('stream');
const OS = require('os');

const sOutfilePath = './unique-names.csv';
const sNamesFolder = './names/';
const streamOut = new Stream;
let oKnownNames = {};

/*
 * group 1 is by default. These files are csv with name in column 4
 * group 2 files are space delimited with name in column 1
 * group 3 files are csv with name in column 1
 */
let groupHandler = {};

groupHandler['1'] = function(sPath, resolve) {
  fStreamNameFile(sPath, ',', 3, resolve);
}

groupHandler['2'] = function(sPath, resolve) {
  fStreamNameFile(sPath, ' ', 0, resolve);
}

groupHandler['3'] = function(sPath, resolve) {
  fStreamNameFile(sPath, ',', 0, resolve);
}

function fStreamNameFile(sPath, sParseCharacter, iColumn, resolve) {
  const streamIn = fs.createReadStream(sPath);
  const _rl = readline.createInterface(streamIn, streamOut);

  _rl.on('line', function(sLine) {
    const sName = sLine.toLowerCase().split(sParseCharacter)[iColumn];
    //console.log(sName);
    oKnownNames[sName] = 1;               // value of 1 isn't special, it's just a performent way to ensure we get this name
  });

  _rl.on('close', ()=>{
    //giConsoleUpdater.next();
    resolve();
  });
}

//ref: http://stackoverflow.com/a/18983245/3931488
//ref: https://ryanpcmcquen.org/javascript/2015/10/25/map-vs-foreach-vs-for.html
fs.readdir(sNamesFolder, (err, files) => {
  let arrpFileProcesses = files.map(file => {
    var sGroupId = file.split('-')[1];
    var fGroupHandler = groupHandler[sGroupId];
    var sPath = sNamesFolder + file;

    return new Promise((resolve) => {
      if (fGroupHandler) {
        fGroupHandler(sPath, resolve);
      } else {
        groupHandler['1'](sPath, resolve);
      }
    });
  });

  Promise.all(arrpFileProcesses).then(() => {
    const streamWriteToFileSystem = fs.createWriteStream(sOutfilePath);
    const sTitleLine = 'First or Last Names';
    // TODO: column first and last name
    // TODO: request from a names list, or loop name + i; i++ until 404
    //    eg /dustinlongenecker public, /johnsmith2 404, /john and /john2 both exist (but private), /john3 exists and public with linkedIn.

    // OS.EOL is a smart way to do a line break. ref: http://stackoverflow.com/questions/14173150/how-do-i-create-a-line-break-in-a-javascript-string-to-feed-to-nodejs-to-write-t
    const sTextToWrite = [sTitleLine].concat(Object.keys(oKnownNames)).join(OS.EOL);

    streamWriteToFileSystem.write(sTextToWrite);
    process.exit(0);
  });
});

// after every batch of 10 files, update console.
// generator pattern. ref: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Closures
// TODO: it doesn't work. Fix or delete.
function* giConsoleUpdaterFactory() {
  //console.log('called');          //it only gets called once...?
  let iFilesCompleted = 0;
  iFilesCompleted++;
  if(iFilesCompleted % 10 === 0) console.log('A batch of 10 files has completed.');
}

let giConsoleUpdater = giConsoleUpdaterFactory();