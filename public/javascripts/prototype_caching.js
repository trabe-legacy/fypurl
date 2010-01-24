/**
 * For caching document.getElementById;
 * If you $() on an element more than once, it only does a
 * document.getElementById the first time.
 * By John Nunemaker
 */
var SpeedyGonzalez = {};
SpeedyGonzalez.Version = '0.1';

Object.extend(SpeedyGonzalez, {
	elements: $A([]),
	
	findElement: function(element) {
		if (!SpeedyGonzalez.elements.include(element)) { SpeedyGonzalez.elements[element] = document.getElementById(element); }
		return SpeedyGonzalez.elements[element];
	}
});

SpeedyGonzalez.$old = $;

function $() {
  var results = [], element;
  for (var i = 0; i < arguments.length; i++) {
    element = arguments[i];
    if (typeof element == 'string') {
			element = SpeedyGonzalez.findElement(element); // only change to prototype's $()
		}
    results.push(Element.extend(element));
  }
  return results.length < 2 ? results[0] : results;
}