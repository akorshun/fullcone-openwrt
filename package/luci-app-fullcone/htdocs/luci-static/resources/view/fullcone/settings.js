'use strict';
'require view';
'require form';
'require fs';

return view.extend({
	load() {
		return L.resolveDefault(fs.stat('/sys/module/nft_fullcone'), null);
	},

	render(module) {
		let m, s, o;

		m = new form.Map('firewall', _('FullCone NAT'),
			_('Full cone NAT (NAT1) for UDP. Once a LAN host has sent a packet from a port, any host on the internet can reach it on the mapped external port. It replaces masquerading in zones that have masquerading enabled; other protocols are masqueraded as before.'));

		s = m.section(form.TypedSection, 'defaults');
		s.anonymous = true;
		s.addremove = false;

		o = s.option(form.DummyValue, '_module', _('Kernel module'));
		o.cfgvalue = () => module
			? _('nft_fullcone is loaded')
			: _('nft_fullcone is not loaded - firewall4 will fall back to masquerading');

		o = s.option(form.Flag, 'fullcone', _('Enable FullCone NAT'),
			_('IPv4, in zones with masquerading enabled.'));

		o = s.option(form.Flag, 'fullcone6', _('Enable FullCone NAT6'),
			_('IPv6, only in zones with IPv6 masquerading enabled. Usually not needed.'));

		return m.render();
	}
});
