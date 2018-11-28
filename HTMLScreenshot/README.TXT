@author Phil
@url 	http://www.idontplaydarts.com/2012/04/taking-screenshots-using-xss-and-the-html5-canvas

The POC XSS example has 2 files.

screenshot.js 	- This is the file that needs to be included in the XSS attack
		- it will post a base64 encoded png to the location defined at 
		- the top of the file. (postDest)

saveshot.php	- This should write the image to test.png

