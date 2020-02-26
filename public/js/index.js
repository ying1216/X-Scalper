'use strict'

let whoami = $('#whoami');
let whoamiButton = $('#whoamiButton');

let buyButton = $('#buyButton');

let update = $('#update');

let ticketList = $('#ticketList');

let transferTo = $('#transferTo');
let ticketValue = $('#ticketValue');
let transferButton = $('#transferButton');

let approvedTicketList = $('#approvedTicketList');

let approvedTicketValue = $('#approvedTicketValue');
let buyApprovedButton = $('#buyApprovedButton');

let refundButton = $('#refundButton');
let refundValue = $('#refundValue');

let etherBalance = $('#etherBalance');
let withdrawButton = $('#withdrawButton');
let withdrawValue = $('#withdrawValue');

let nowAccount = "";



// 載入使用者至 select tag
$.get('/accounts', function (accounts) {
	for (let account of accounts) {
		whoami.append(`<option value="${account}">${account}</option>`)
	}
	nowAccount = whoami.val();
})

// 當按下登入按鍵時
whoamiButton.on('click', async function () {
	nowAccount = whoami.val();
	update.trigger('click')
	console.log("test")
})

update.on('click', function () {
	console.log("bobedee")
	$.get('/allTickets', {
		account: nowAccount
	}, function (result) {
		ticketList.empty();
		for (let _ticket of result._tickets) {
			if (parseInt(_ticket) !== 1) {
				continue;
			}
			ticketList.append(
				`<li class="list-group-item">
					${_ticket}
				</li>`
			)
		}
	})

	$.get('/allApprovedTickets', {
		account: nowAccount
	}, function (result) {
		approvedTicketList.empty();
		for (let _ticket of result._tickets) {
			if (parseInt(_ticket) !== 1) {
				continue;
			}
			approvedTicketList.append(
				`<li class="list-group-item">
					${_ticket}
				</li>`
			)
		}
	})

	$.get('/etherBalance', {
		account: nowAccount
	}, function (result) {
		etherBalance.text('Ether Balance: ' + result.balance)
	})
})

buyButton.on('click', async function () {
	$.post('/buyTicket', {
		account: nowAccount
	}, function (result) {
		if(result.events !== undefined) {
			update.trigger('click'),
			console.log(result.events)
			
		}else{
			console.log(result)
		}
	})
})

// 當按下贈與按鍵時
transferButton.on('click', async function () {
	// 解鎖
	let unlock = await unlockAccount();
	if (!unlock) {
		return;
	}

	// 交易
	$.post('/transfer', {
		account: nowAccount,
		to: transferTo.val(),
		value: parseInt(ticketValue.val(), 10)
	}, function (result) {
		if (result.events !== undefined) {
			// 觸發更新帳戶資料
			update.trigger('click')
			$('#transferTo').val('')
			$('#ticketValue').val('')
		}
		
	})
})

buyApprovedButton.on('click', async function () {
	// 解鎖
	let unlock = await unlockAccount();
	if (!unlock) {
		return;
	}

	// 交易
	$.post('/buyApproved', {
		account: nowAccount,
		value: parseInt(approvedTicketValue.val(), 10)
	}, function (result) {
		console.log("a")
		if (result.events !== undefined) {
			// 觸發更新帳戶資料
			update.trigger('click')
			$('#approvedTicketValue').val('')
		}
		
	})
})

// 退票時
refundButton.on('click', async function () {
	// 解鎖
	let unlock = await unlockAccount();
	if (!unlock) {
		console.log("tutut")
		return;
	}

	// 退票
	$.post('/refund', {
		account: nowAccount,
		value: refundValue.val()
	}, function (result) {
		if (result.events !== undefined) {
			// 觸發更新帳戶資料
			update.trigger('click')
			$('#refundValue').val('')
		}
		
	})
})

// 取回Ether
withdrawButton.on('click', async function () {
	// 解鎖
	let unlock = await unlockAccount();
	if (!unlock) {
		return;
	}

	// 轉帳
	$.post('/withdraw', {
		account: nowAccount,
		value: parseInt(withdrawValue.val(), 10)
	}, function (result) {
		if (result.events !== undefined) {
			// 觸發更新帳戶資料
			update.trigger('click')
			$('#withdrawValue').val('')
		}
	})
})

function waitTransactionStatus() {
	$('#accountStatus').html('帳戶狀態 <b style="color: blue">(等待交易驗證中...)</b>')
}

function doneTransactionStatus() {
	$('#accountStatus').text('帳戶狀態')
}

async function unlockAccount() {
	let password = prompt("請輸入你的密碼", "");
	if (password == null) {
		return false;
	}
	else {
		return $.post('/unlock', {
			account: nowAccount,
			password: password
		})
			.then(function (result) {
				if (result == 'true') {
					return true;
				}
				else {
					alert("密碼錯誤")
					return false;
				}
			})
	}
}