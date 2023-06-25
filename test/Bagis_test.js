const assert = require('assert').strict;

const Bagis = artifacts.require('KriptoBagis');

contract('Bagis', (accounts) => {
	describe('deposit:', () => {
		// TODO add a test for the version of the function that does not expect a donation amount.
        it('Yeni hesapları ekle', async () => {

            var deployer = accounts[0];

        //const mytest = await MyContract.deployed().then(instance => instance.set("Yeni string değerim!").then(assert(instance.get(),"Yeni string degerim","String değişmedi yine")));;       
			const mytest = await Bagis.deployed();

			const initial = await web3.eth.getBalance(accounts[1]);
			console.log(`Initial: ${initial.toString()}`);


			//const test1 = await mytest.addNewOrganization("Kizilay", [0, 3, 5], {from: accounts[3]});

			const test2 = await mytest.addNewOrganization("Unicef", [6,7], {from: accounts[8]});

			const test3 = await mytest.addNewOrganization("Mehmetçik", [3,6], {from: accounts[7]});


			//const output1 = await mytest.getAddress({from: accounts[3]})

			const output2 = await mytest.getAddress({from: accounts[8]})

			const output3 = await mytest.getAddress({from: accounts[7]})

			// console.log("1. Hesap", output1.organizationName);
			// console.log(`result: ${output1}`);
			// console.log(test1.gasUsed);

			console.log("2. Hesap", output2.organizationName);
			console.log(`result: ${output2}`);

			console.log("3. Hesap", output3.organizationName);
			console.log(`result: ${output3}`);

			//,[accounts[4],accounts[5]],50

			
			const transferAmount = Number(web3.utils.toWei('5', 'ether'));


			//const test5 = await mytest.addNewOrganization("Mehmetçik", [3,6], {from: accounts[5]});

			//await mytest.depositDirect(accounts[4], 50, {from:accounts[1], value: transferAmount, gas: 3000000});//.sendTransaction()  {from:accounts[1], value:'5e18'}

			await mytest.deposit(accounts[8], [accounts[7]] , 80, {from:accounts[9], value: transferAmount, gas: 3000000});

			const depositedAddress = await web3.eth.getBalance(accounts[4]);
			console.log(`Wallet [4]: ${depositedAddress.toString()}`);


			const totalDonationsAmount = await mytest.getTotalDonationsAmount();
			console.log(`Total donation: ${totalDonationsAmount.toString()}`);
		// 	assert.equal(Number(totalDonationsAmount), donationAmount)


        });



		// it('Kripto bağış testi, ', async () => {
		// 	const instance = await Bagis.deployed();

		// 	// const addresses = await instance.getAddresses.call();
		// 	// console.log('addresses: ' + JSON.stringify(addresses, null, 4));

		// 	const balances ={
		// 		before: {
		// 			contract: await web3.eth.getBalance(instance.address),
		// 			account4: await web3.eth.getBalance(accounts[4]),
		// 			account5: await web3.eth.getBalance(accounts[5]),
		// 			account6: await web3.eth.getBalance(accounts[6]),
		// 		},
		// 		after: {
		// 			contract: null,
		// 			account4: null,
		// 			account5: null,
		// 			account6: null
		// 		}
		// 	};

		// 	const destinationAddress = accounts[4];
        //     const otherAddresses = [accounts[5],accounts[6]];
        //     const mainPercentage = 40;
		// 	const transferAmount = Number(web3.utils.toWei('1', 'ether')) / 2;
		// 	const donationAmount = transferAmount / 2;
		// 	await instance.deposit(destinationAddress, otherAddresses, mainPercentage, {
		// 		from: accounts[3],
		// 		value: transferAmount
		// 	});

		// 	balances.after.contract = await web3.eth.getBalance(instance.address);
		// 	balances.after.account4 = await web3.eth.getBalance(accounts[4]);
		// 	balances.after.account5 = await web3.eth.getBalance(accounts[5]);

		// 	assert.equal(balances.before.contract, balances.after.contract);
		// 	assert.equal(balances.before.account4, balances.after.account4);
		// 	assert.notEqual(balances.before.account6, balances.after.account6);
		// 	assert.notEqual(balances.before.account5, balances.after.account5);
		// 	assert.equal(Number(balances.after.account4), Number(balances.before.account4) + donationAmount);

		// 	const totalDonationsAmount = await instance.getTotalDonationsAmount();
		// 	assert.equal(Number(totalDonationsAmount), donationAmount)

		// 	const highestDonationResults = await instance.getHighestDonation();
		// 	const highestDonation = highestDonationResults[4];
		// 	const highestDonor = highestDonationResults[5];

		// 	assert.equal(Number(highestDonation), donationAmount);
		// 	assert.equal(highestDonor, accounts[6]);
		// });





		// it('Should properly deposit the donation and transfer amount '
		// 		+ 'when the sender is specified, for multiple transfers.', async () => {
		// 	const instance = await Charitable.deployed();

		// 	const balances ={
		// 		before: {
		// 			contract: await web3.eth.getBalance(instance.address),
		// 			account0: await web3.eth.getBalance(accounts[0]),
		// 			account1: await web3.eth.getBalance(accounts[1])
		// 		},
		// 		after: {
		// 			contract: null,
		// 			account0: null,
		// 			account1: null
		// 		}
		// 	};

		// 	const destinationAddress = accounts[1];
		// 	const charityIndex = 1;
		// 	const transferAmount = Number(web3.utils.toWei('1', 'ether'));
		// 	const donationAmount1 = transferAmount / 3;
		// 	const donationAmount2 = transferAmount / 4;

		// 	await instance.deposit(destinationAddress, charityIndex, donationAmount1.toString(), {
		// 		value: transferAmount
		// 	});

		// 	await instance.deposit(destinationAddress, charityIndex, donationAmount2.toString(), {
		// 		value: transferAmount
		// 	});

		// 	balances.after.contract = await web3.eth.getBalance(instance.address);
		// 	balances.after.account0 = await web3.eth.getBalance(accounts[0]);
		// 	balances.after.account1 = await web3.eth.getBalance(accounts[1]);

		// 	assert.equal(balances.before.contract, balances.after.contract);
		// 	assert.notEqual(balances.before.account0, balances.after.account0);
		// 	assert.notEqual(balances.before.account1, balances.after.account1);
		// 	assert.equal(Number(balances.after.account1), Number(balances.before.account1) + transferAmount * 2 -  (donationAmount1 + donationAmount2));

		// 	const totalDonationsAmount = await instance.getTotalDonationsAmount();
		// 	assert.equal(Number(totalDonationsAmount), 833333333333333200)

		// 	const highestDonationResults = await instance.getHighestDonation();
		// 	const highestDonation = highestDonationResults[0];
		// 	const highestDonor = highestDonationResults[1];

		// 	assert.equal(Number(highestDonation), 333333333333333300);
		// 	assert.equal(highestDonor, accounts[0]);

		// 	// await instance.destroy.call();
		// 	//
		// 	// const highestDonationResults2 = await instance.getHighestDonation.call();
		// 	//
		// 	// console.log('highestDonation: ' + highestDonationResults2[0]);
		// 	// console.log('highestDonor: ' + highestDonationResults2[1]);
		// })
	});
});