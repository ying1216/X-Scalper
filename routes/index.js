const express = require('express');
const router = express.Router();

const Web3 = require('web3');

const web3 = new Web3('http://localhost:8545');

const contract = require('../contract/Ticket.json');

let ticket = new web3.eth.Contract(contract.abi);
ticket.options.address = "0x28312ac0ff20a7f030417e7f3ac364c474ecc6ce";//Deployed address

_ticketId = 1;

/* GET home page. */
router.get('/', async function (req, res, next) {
  res.render('index')
});

//get accounts
router.get('/accounts', async function (req, res, next) {
  let accounts = await web3.eth.getAccounts()
  res.send(accounts)
});

//show tickets
router.get('/allTickets', async function (req, res, next) {
  console.log("Bibidee")
  let _tickets = await ticket.methods.getOwnerTicketId(req.query.account).call({
    from: req.query.account
  })
  res.send({
    _tickets:_tickets 
     
  })
});

//buy ticket
router.post('/buyTicket', async function (req, res, next) {
  console.log('Hello!')
  ticket.methods.buyTicket(_ticketId).send({
    from: req.body.account,
    value:web3.utils.toWei('0.5','ether'),
    gas: 3400000
  })
    .on('receipt', function (receipt) {
      _ticketId += 1;
      res.send(receipt);
    })
    .on('error', function (error) {
      res.send(error.toString());
    })
});

//unlock account
router.post('/unlock', function (req, res, next) {
  web3.eth.personal.unlockAccount(req.body.account, req.body.password, 60)
    .then(function (result) {
      res.send('true')
    })
    .catch(function (err) {
      res.send('false')
    })
});

//transfer ticket
router.post('/transfer', function (req, res, next) {
  //approve
  console.log("asdf")
  ticket.methods.approve(req.body.to, req.body.value).send({
    from: req.body.account,
    gas: 3400000
  })
    .on('receipt', function (receipt) {
      res.send(receipt)
    })
    .on('error', function (error) {
      res.send(error.toString())
    })
  console.log("asdf")
});

router.get('/allApprovedTickets', async function (req, res, next) {
  console.log("Bibidee")
  let _tickets = await ticket.methods.getApproveTicketId(req.query.account).call({
    from: req.query.account
  })
  res.send({
    _tickets:_tickets 
  })
});

router.post('/buyApproved', function (req, res, next) {
  ticket.methods.buyOthersTicket(req.body.value).send({
    from: req.body.account,
    value: web3.utils.toWei('0.5','ether'),
    gas: 3400000
  })
    .on('receipt', function (receipt) {
      res.send(receipt)
    })
    .on('error', function (error) {
      res.send(error.toString())
    })
});

//refund
router.post('/refund', function (req, res, next) {
  console.log("Fail")
  ticket.methods.refund(req.body.value).send({
    from: req.body.account,
    gas: 3400000
  })
    .on('receipt', function (receipt) {
      res.send(receipt);
    })
    .on('error', function (error) {
      res.send(error.toString());
    })
});

router.get('/etherBalance', async function (req, res, next) {
  console.log("Bibidee")
  let _balance = await ticket.methods.getEtherBalance().call({
    from: req.query.account
  })
  res.send({
    balance: _balance 
  })
});

//withdraw ether
router.post('/withdraw', function (req, res, next) {
  ticket.methods.withdraw(req.body.value).send({
    from: req.body.account,
    gas: 3400000
  })
    .on('receipt', function (receipt) {
      res.send(receipt);
    })
    .on('error', function (error) {
      res.send(error.toString());
    })
});


module.exports = router;
