(function(){

	var fill = new ol.style.Fill({color: ''});
	var stroke = new ol.style.Stroke({color: '', width: 1});
	var polygon = new ol.style.Style({fill: fill});
	var strokedPolygon = new ol.style.Style({fill: fill, stroke: stroke});
	var line = new ol.style.Style({stroke: stroke});
	var text = new ol.style.Style({text: new ol.style.Text({
		text: '', fill: fill, stroke: stroke
	})});
	var iconCache = {};

	var getIcon = function(iconName) {
		var icon = iconCache[iconName];
		if (!icon) {
			icon = new ol.style.Style({image: new ol.style.Icon({
			src: 'https://cdn.rawgit.com/mapbox/maki/master/icons/' + iconName + '-15.svg',
			imgSize: [15, 15]
			})});
			iconCache[iconName] = icon;
		}
		return icon;
	}

	var styles = [];

	//return a function that can be used by ol
	var gretchenStyle = function(){
		return function(feature, resolution){

			var styles = [];
			var length = 0;

			var layer = feature.get('layer');
		    var cls = feature.get('class');
		    var type = feature.get('type');
		    var scalerank = feature.get('scalerank');
		    var labelrank = feature.get('labelrank');
		    var adminLevel = feature.get('admin_level');
		    var maritime = feature.get('maritime');
		    var disputed = feature.get('disputed');
		    var maki = feature.get('maki');
		    var geom = feature.getGeometry().getType();

		    //console.log('style:',feature,resolution);

		    //  tegola debug styles
			if (layer == 'debug' && type == 'debug_outline'){
				//  outline our tile
				stroke.setColor('#f00');
				stroke.setWidth(1);
				styles[length++] = line;
			} else if (layer == 'debug' && type == 'debug_text'){
				//  write z, x, y values
				text.getText().setText(feature.get('zxy'));
				text.getText().setFont('11px "Open Sans", "Arial Unicode MS"');
				fill.setColor('#333');
				stroke.setColor('rgba(255,255,255,0.8)');
				stroke.setWidth(1);
				styles[length++] = text;
			}

			if (layer == 'water') {
				fill.setColor('hsl(206, 50%, 80%)');
				styles[length++] = polygon;
			} else if (layer == 'grassland') {
		      fill.setColor('hsla(125, 44%, 63%, 0.56)');
		      stroke.setColor('hsla(125, 44%, 63%, 0.56)');
		      stroke.setWidth(0.3);
		      styles[length++] = strokedPolygon;
		    } else if (layer == 'residential') {
		      fill.setColor('hsl(96, 43%, 86%)');
		      stroke.setColor('hsla(96, 18%, 88%, 0)');
		      stroke.setWidth(0.3);
		      styles[length++] = strokedPolygon;
		    } else if (layer == 'building') {
				fill.setColor('hsl(0, 2%, 76%)');
				stroke.setColor('hsl(0, 0%, 100%)');
				stroke.setWidth(1);
				styles[length++] = strokedPolygon;
		    } else if (layer == 'medical_polygon') {
		      fill.setColor('hsl(15, 77%, 46%)');
		      stroke.setColor('hsl(15, 77%, 46%)');
		      stroke.setWidth(0.3);
		      styles[length++] = strokedPolygon;
		    } else if (layer == 'military') {
		      fill.setColor('hsl(0, 0%, 39%)');
		      stroke.setColor('hsl(0, 0%, 39%)');
		      stroke.setWidth(0.3);
		      styles[length++] = strokedPolygon;
		    } else if (layer == 'farms') {
		      fill.setColor('#259b24');
		      stroke.setColor('#249a23');
		      stroke.setWidth(0.3);
		      styles[length++] = strokedPolygon;
		    } else if (layer == 'forest') {
		      fill.setColor('#259b24');
		      stroke.setColor('#249a23');
		      stroke.setWidth(0.3);
		      styles[length++] = strokedPolygon;
		    } else if (layer == 'schools_polygon') {
		      fill.setColor('hsl(0, 39%, 53%)');
		      stroke.setColor('hsl(0, 39%, 53%)');
		      stroke.setWidth(0.3);
		      styles[length++] = strokedPolygon;
		    } else if (layer == 'river' ) {
				stroke.setColor('hsl(206, 52%, 20%)');
				stroke.setWidth(1);
				styles[length++] = line;
			} else if (layer == 'lakes') {
				fill.setColor('hsl(206, 50%, 80%)');
				stroke.setColor('hsl(206, 52%, 20%)');
				stroke.setWidth(0.3);
				styles[length++] = strokedPolygon;
			} else if (layer == 'road') {
		      stroke.setColor('hsl(266, 1%, 71%)');
		      stroke.setWidth(0.5);
		      styles[length++] = line;
		    } else if (layer == 'main_roads') {
		      stroke.setColor('hsl(266, 15%, 44%)');
		      stroke.setWidth(1);
		      styles[length++] = line;
		    } else if (layer == 'waterway' && cls == 'river') {
				stroke.setColor('hsl(206, 52%, 20%)');
				stroke.setWidth(1);
				styles[length++] = line;
			} else if (layer == 'waterway' && (cls == 'stream' ||
				cls == 'canal')) {
				stroke.setColor('hsl(206, 52%, 20%)');
				stroke.setWidth(1);
				styles[length++] = line;
			} else if (layer == 'water') {
				fill.setColor('hsl(206, 50%, 80%)');
				styles[length++] = polygon;
			} else if (layer == 'landuse' && cls == 'park') {
				fill.setColor('hsl(57, 100%, 97%)');
				styles[length++] = polygon;

			//labels
		    } else if (layer == 'country_label' && scalerank === 1) {
		      text.getText().setText(feature.get('name_en'));
		      text.getText().setFont('bold 11px "Open Sans", "Arial Unicode MS"');
		      fill.setColor('hsl(0, 39%, 53%)');
		      stroke.setColor('hsl(57, 100%, 97%)');
		      stroke.setWidth(2);
		      styles[length++] = text;
		    } else if (layer == 'country_label' && scalerank === 2 &&
		        resolution <= 19567.87924100512) {
		      text.getText().setText(feature.get('name_en'));
		      text.getText().setFont('bold 10px "Open Sans", "Arial Unicode MS"');
		      fill.setColor('hsl(0, 39%, 53%)');
		      stroke.setColor('hsl(57, 100%, 97%)');
		      stroke.setWidth(2);
		      styles[length++] = text;
		    } else if (layer == 'country_label' && scalerank === 3 &&
		        resolution <= 9783.93962050256) {
		      text.getText().setText(feature.get('name_en'));
		      text.getText().setFont('bold 9px "Open Sans", "Arial Unicode MS"');
		      fill.setColor('hsl(0, 39%, 53%)');
		      stroke.setColor('hsl(57, 100%, 97%)');
		      stroke.setWidth(2);
		      styles[length++] = text;
		    } else if (layer == 'country_label' && scalerank === 4 &&
		        resolution <= 4891.96981025128) {
		      text.getText().setText(feature.get('name_en'));
		      text.getText().setFont('bold 8px "Open Sans", "Arial Unicode MS"');
		      fill.setColor('hsl(0, 39%, 53%)');
		      stroke.setColor('hsl(57, 100%, 97%)');
		      stroke.setWidth(2);
		      styles[length++] = text;
		    } else if (layer == 'marine_label' && labelrank === 1 &&
		        geom == 'Point') {
		      text.getText().setText(feature.get('name_en'));
		      text.getText().setFont(
		          'italic 11px "Open Sans", "Arial Unicode MS"');
		      fill.setColor('hsl(206, 26%, 53%)');
		      stroke.setColor('hsl(57, 100%, 97%)');
		      stroke.setWidth(1);
		      styles[length++] = text;
		    } else if (layer == 'marine_label' && labelrank === 2 &&
		        geom == 'Point') {
		      text.getText().setText(feature.get('name_en'));
		      text.getText().setFont(
		          'italic 11px "Open Sans", "Arial Unicode MS"');
		      fill.setColor('hsl(206, 26%, 53%)');
		      stroke.setColor('hsl(57, 100%, 97%)');
		      stroke.setWidth(1);
		      styles[length++] = text;
		    } else if (layer == 'marine_label' && labelrank === 3 &&
		        geom == 'Point') {
		      text.getText().setText(feature.get('name_en'));
		      text.getText().setFont(
		          'italic 10px "Open Sans", "Arial Unicode MS"');
		      fill.setColor('hsl(206, 26%, 53%)');
		      stroke.setColor('hsl(57, 100%, 97%)');
		      stroke.setWidth(1);
		      styles[length++] = text;
		    } else if (layer == 'marine_label' && labelrank === 4 &&
		        geom == 'Point') {
		      text.getText().setText(feature.get('name_en'));
		      text.getText().setFont(
		          'italic 9px "Open Sans", "Arial Unicode MS"');
		      fill.setColor('hsl(206, 26%, 53%)');
		      stroke.setColor('hsl(57, 100%, 97%)');
		      stroke.setWidth(1);
		      styles[length++] = text;
		    } else if (layer == 'place_label' && type == 'city' &&
		        resolution <= 1222.99245256282) {
		      text.getText().setText(feature.get('name_en'));
		      text.getText().setFont('11px "Open Sans", "Arial Unicode MS"');
		      fill.setColor('hsl(0, 0%, 20%)');
		      stroke.setColor('hsl(57, 100%, 97%)');
		      stroke.setWidth(1);
		      styles[length++] = text;
		    } else if (layer == 'place_label' && type == 'town' &&
		        resolution <= 305.748113140705) {
		      text.getText().setText(feature.get('name_en'));
		      text.getText().setFont('9px "Open Sans", "Arial Unicode MS"');
		      fill.setColor('hsl(0, 0%, 20%)');
		      stroke.setColor('hsl(57, 100%, 97%)');
		      stroke.setWidth(1);
		      styles[length++] = text;
		    } else if (layer == 'place_label' && type == 'village' &&
		        resolution <= 38.21851414258813) {
		      text.getText().setText(feature.get('name_en'));
		      text.getText().setFont('8px "Open Sans", "Arial Unicode MS"');
		      fill.setColor('hsl(0, 0%, 20%)');
		      stroke.setColor('hsl(57, 100%, 97%)');
		      stroke.setWidth(1);
		      styles[length++] = text;
		    } else if (layer == 'place_label' &&
		        resolution <= 19.109257071294063 && (type == 'hamlet' ||
		        type == 'suburb' || type == 'neighbourhood')) {
		      text.getText().setText(feature.get('name_en'));
		      text.getText().setFont('bold 9px "Arial Narrow"');
		      fill.setColor('hsl(0, 0%, 20%)');
		      stroke.setColor('hsl(57, 100%, 97%)');
		      stroke.setWidth(1);
		      styles[length++] = text;
		    } else if (layer == 'poi_label' && resolution <= 19.109257071294063 &&
		        scalerank == 1 && maki !== 'marker') {
		      styles[length++] = getIcon(maki);
		    } else if (layer == 'poi_label' && resolution <= 9.554628535647032 &&
		        scalerank == 2 && maki !== 'marker') {
		      styles[length++] = getIcon(maki);
		    } else if (layer == 'poi_label' && resolution <= 4.777314267823516 &&
		        scalerank == 3 && maki !== 'marker') {
		      styles[length++] = getIcon(maki);
		    } else if (layer == 'poi_label' && resolution <= 2.388657133911758 &&
		        scalerank == 4 && maki !== 'marker') {
		      styles[length++] = getIcon(maki);
		    } else if (layer == 'poi_label' && resolution <= 1.194328566955879 &&
		        scalerank >= 5 && maki !== 'marker') {
		      styles[length++] = getIcon(maki);
		    }




			       

			return styles;


		};
	}

	window.gretchenStyle = gretchenStyle;
})();

