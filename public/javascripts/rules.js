/*
 * reglas para behaviour
 */
var myrules = {
	'#notice' : function(div) {
        var actions = document.createElement('div');
        actions.className = 'flash_actions';
        actions.innerHTML = '<a href="#" title="Close this message" onclick="this.parentNode.parentNode.style.display = \'none\'; return false;">[Close]</a>';
        div.appendChild(actions);
	}
};

Behaviour.register(myrules);