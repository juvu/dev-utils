/*

USE:

$.get( 'https://raw.githubusercontent.com/flaviolsousa/dev-utils/master/js/snippet/responsivo/fill-checkout.js?_=' + Date.now(), d=>eval(d));

*/
/*jshint esversion: 6 */
function pageLoaded() {
	$('span:contains("Nome")').next('input').val((i, v)=>'FLAVIO' + String.fromCharCode(65 + i)).blur();
	$('span:contains("Sobrenome")').next('input').val('SOUSA').blur();
	$('span:contains("Data de Nascimento")').next('input').val('01/01/1980').blur();
	$('span:contains("CPF")').next('input').val('012.345.678-90').blur();
	$('input.phone').val('(11) 22222-3333').blur();
	$('input.emailConfirm').val('timesite@cvc.com.br').blur();
	$('input.number.simulacrum-input').val('4242 4242 4242 4242').blur();
	$('input.cardDate.simulacrum-input').val('01/2025').blur();
	$('input.cardName.simulacrum-input').val('teste').blur();
	$('input.cardCVV.simulacrum-input').val('123').blur();
	$('h3:contains("Criança"):not([id])').parent().each((i, v) => {
		let jv = $(v);
		let idade = 0 + jv.find('h3').text().replace(/[\r\n\s]+/g, '').replace(/.*a(\d+?)ano.*/, '$1');
		jv.find('span:contains("Data de Nascimento"):not([id])').next('input').val('01/01/' + ((new Date()).getFullYear()-idade)).blur();
	});
	$('h3:contains("Bebê"):not([id])').parent().find('span:contains("Data de Nascimento"):not([id])').next('input').val('01/01/' + (new Date()).getFullYear()).blur();
	
	let jCheckDeclaro = $('span:contains("Declaro que li as"):not([id])').parent().find('input');
	if (!jCheckDeclaro[0].checked) {
		jCheckDeclaro.click();
	}
	
	$("html, body").animate({ scrollTop: $(document).height() }, 1000);
	

	let countCheckEndereco = 0;
	$('span:contains("CEP"):not([id])').parent().find('input').val('09070-000').blur();
	function setAllEndereco() {
		console.log('FLS: setAllEndereco');
		$('span:contains("Endereço"):not([id])').parent().find('input').val('Rua Miranda').blur();
		$('span:contains("Número"):not([id])').parent().find('input.addressNumber').val('123').blur();
		$('span:contains("Cidade"):not([id])').parent().find('input').val('Santo Andre').blur();
		$('span:contains("Bairro"):not([id])').parent().find('input').val('Campestre').blur();
		$('span:contains("Estado"):not([id])').parent().find('select').val('SP').click().change();

		console.log('FLS: end');
	}
	function setEndereco() {
		console.log('FLS: setEndereco');
		$('span:contains("Número"):not([id])').parent().find('input.addressNumber').val('123').blur();

		console.log('FLS: end');
	}
	function checkEndereco() {
		console.log('FLS: waitSearchCep');
		if ($('span:contains("CEP"):not([id])').parent().find('.general-loader').size() == 1) {
			setTimeout(checkEndereco, 500);
		} else {
			if ($('span:contains("Endereço"):not([id])').parent().find('input').val() == '') {
				if (countCheckEndereco++ < 1) {
					$('span:contains("CEP"):not([id])').parent().find('input').blur();
					setTimeout(checkEndereco, 500);
				} else {
					setAllEndereco();
				}
			} else {
				setEndereco();
			}
		}
	}
	setTimeout(checkEndereco, 1000);
	
}

function waitPageLoad() {
	if ($(".general-loader-overlay").size() > 0) {
		setTimeout(waitPageLoad, 500);
		console.log('FLS: waitPageLoad');
	} else {
		pageLoaded();
		console.log('FLS: pageLoaded');
	}
}

waitPageLoad();