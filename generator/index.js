import fs from "fs";
import util from "ethereumjs-util";
import randomstring from "randomstring";
import rimraf from "rimraf";

function createNodeKey( kind, index ) {
  fs.mkdirSync( `/${kind}s/${index}/keys`, { recursive: true } );
  fs.mkdirSync( `/${kind}s/${index}/data`, { recursive: true } );
  const privateKey = randomstring.generate( { length: 64, charset: 'hex' } );
  const publicKey = util.privateToPublic( Buffer.from( privateKey, 'hex' ) ).toString( 'hex' );
  fs.writeFileSync( `/${kind}s/${index}/keys/key`, privateKey );
  fs.writeFileSync( `/${kind}s/${index}/keys/key.pub`, publicKey );
  console.log( `Generating ${kind}${index}` );
}

const { VALIDATORS, WRITERS } = process.env;

rimraf.sync('/validators/*' );
rimraf.sync('/writers/*' );

for( let i = 1; i <= VALIDATORS; i++ ) {
  createNodeKey( 'validator', i );
}

for( let i = 1; i <= WRITERS; i++ ) {
  createNodeKey( 'writer', i );
}
