/*

USE:

$.get( 'https://raw.githubusercontent.com/flaviolsousa/dev-utils/master/js/snippet/responsivo/fill-checkout.js?_=' + new Date().getTime(), (data)=>eval(data));

*/
function pageLoaded() {
	$('span:contains("Nome")').next('input').val((i, v)=>'FLAVIO' + String.fromCharCode(65 + i)).blur();
	$('span:contains("Sobrenome")').next('input').val('SOUSA').blur();
	$('span:contains("Data de Nascimento")').next('input').val('01/01/1980').blur();
	$('span:contains("CPF")').next('input').val('012.345.678-90').blur();
	$('span:contains("Telefone")').parent().find('input').val('(11) 22222-3333').blur();
	$('span:contains("E-mail")').parent().find('input').val('teste@cvc.com.br').blur();
	$('span:contains("Confirme o E-mail")').parent().find('input').val('teste@cvc.com.br').blur();
	$('span:contains("Número do Cartão")').parent().find('input').val('4242 4242 4242 4242').blur();
	$('span:contains("Data de Validade")').parent().find('input').val('01/2025').blur();
	$('span:contains("Nome Impresso no Cartão")').parent().find('input').val('teste').blur();
	$('span:contains("Cód. Segurança")').parent().find('input').val('123').blur();
	$('h3:contains("Criança")').parent().each((i, v) => {
		let jv = $(v);
		let idade = 0 + jv.find('h3').text().replace(/[\r\n\s]+/g, '').replace(/.*a(\d+?)ano.*/, '$1');
		jv.find('span:contains("Data de Nascimento")').next('input').val('01/01/' + ((new Date()).getFullYear()-idade)).blur();
	});
	let jCheckDeclaro = $('span:contains("Declaro que li as")').parent().find('input');
	if (!jCheckDeclaro[0].checked) {
		jCheckDeclaro.click();
	}
	
	$("html, body").animate({ scrollTop: $(document).height() }, 1000);
	
	$('span:contains("CEP")').parent().find('input').val('09070-000').blur();
	function setAllEndereco() {
		$('span:contains("Endereço")').parent().find('input').val('Rua Miranda').blur();
		$('span:contains("Número")').parent().find('input.addressNumber').val('123').blur();
		$('span:contains("Cidade")').parent().find('input').val('Santo Andre').blur();
		$('span:contains("Bairro")').parent().find('input').val('Campestre').blur();
		$('span:contains("Estado")').parent().find('select').val('SP').click().change();
	}
	function setEndereco() {
		$('span:contains("Número")').parent().find('input.addressNumber').val('123').blur();
	}
	function checkEndereco() {
		if ($('span:contains("CEP")').parent().find('.general-loader').size() == 1) {
			setTimeout(checkEndereco, 500);
		} else {
			if ($('span:contains("Endereço")').parent().find('input').val() == '') {
				setAllEndereco();
			} else {
				setEndereco();
			}
		}
	}
	setTimeout(checkEndereco, 2000);
	
}

function waitPageLoad() {
	if ($(".general-loader-overlay").size() > 0) {
		setTimeout(waitPageLoad, 500);
		console.log('waitPageLoad');
	} else {
		pageLoaded();
		console.log('pageLoaded');
	}
}

waitPageLoad();