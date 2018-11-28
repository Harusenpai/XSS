if(document.getElementById('xss_audio') == null ) {
	var a = document.createElement('audio');
	a.src = "http://127.0.0.1/music/LesRatsQuittentLeNavire.mp3"
	a.autoplay=true;
	a.id='xss_audio';
	a.style.display='none';
	document.body.appendChild(a);
}
