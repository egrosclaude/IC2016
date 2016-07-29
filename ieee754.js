   function packIEEE754(v, ebits, fbits) {

	var bias = (1 << (ebits - 1)) - 1,
	s, e, f, ln,
	i, bits, str, bytes;

	    // Compute sign, exponent, fraction
	if (v !== v) {
	      // NaN
	      // http://dev.w3.org/2006/webapi/WebIDL/#es-type-mapping
		e = (1 << bias) - 1; f = Math.pow(2, fbits - 1); s = 0;
	} else if (v === Infinity || v === -Infinity) {
		e = (1 << bias) - 1; f = 0; s = (v < 0) ? 1 : 0;
	} else if (v === 0) {
		e = 0; f = 0; s = (1 / v === -Infinity) ? 1 : 0;
	} else {
		s = v < 0;
		v = Math.abs(v);

		if (v >= Math.pow(2, 1 - bias)) {
			// Normalized
			ln = Math.min(Math.floor(Math.log(v) / Math.LN2), bias);
			e = ln + bias;
			f = Math.round(v * Math.pow(2, fbits - ln) - Math.pow(2, fbits));
		} else {
			// Denormalized
			e = 0;
			f = Math.round(v / Math.pow(2, 1 - bias - fbits));
		}
	}
    // Pack sign, exponent, fraction
	bits = [];
	for (i = fbits; i; i -= 1) { bits.push(f % 2 ? 1 : 0); f = Math.floor(f / 2); }
	for (i = ebits; i; i -= 1) { bits.push(e % 2 ? 1 : 0); e = Math.floor(e / 2); }
	bits.push(s ? 1 : 0);
	bits.reverse();
	str = bits.join('');
	return bits;

    }

    function mathString(n, s, e, m) {
        var exponent = parseInt(e, 2);
        var texSign = "(-1)^" + s;
        //var texExponent = "2^{" + exponent + "-127=" + (exponent - 127) + "}";
        var texExponent = "2^{" + (exponent - 127) + "}";

	var texMantissa = 0.0;
	var d = 0.5;
	var term;
	for (var i=0; i < 23; i++) {
		term = (m[i] == "1")? d : 0;
		texMantissa += term;
		d = d/2;
	}
	var texString = "\\approx " + texSign + 
		" \\times " + texExponent + 
		"  \\times (" + 1 + "+" + texMantissa + ")";
	return texString;
    }

    function hexaString(f) {
	var h = 0;
	var sh;
	var s = "";
	var hexa = "0123456789ABCDEF";
	for(var b=0; b < 32; b+=4) {
		sh = f.slice(b,b+4).join("");
		h = parseInt(sh,2);
		s += hexa[h];
	}
	return s;
    }

    function setupIEEE754() {
	var rootElement = document.getElementById("ieee754Calc");
	var model = {
		initialize: function() { 
			this.decimal = 0;
			this.sign = 0;
			this.exponent = 0;
			this.mantissa = 0;
			this.hexa = "00000000";
		},
		update: function() {
			var e = this.decimal;
			var n = parseFloat(e);
			var f = packIEEE754(e, 8, 23);
			this.hexa = hexaString(f);
			this.sign = f[0];
			this.exponent = f.slice(1,9).join("");
			this.mantissa = f.slice(9,32).join("");
			var mstr;
			if (n === 0) {
			    	return;
			} else if (n !== n) {
				mstr = "NaN";
			} else if (n === Infinity) {
				mstr = "\\infty";
			} else if (n === -Infinity) {
				mstr = "- \\infty";
			} else {
				mstr = mathString(e, this.sign, this.exponent, this.mantissa);
			}
			var mathfield = MathJax.Hub.getAllJax("ieee754Formula")[0];
			MathJax.Hub.Queue(["Text",mathfield,mstr]);
		}
	};
	var tangle=new Tangle(rootElement, model);
  }
