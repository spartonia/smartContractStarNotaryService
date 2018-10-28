const StarNotary = artifacts.require('StarNotary')

contract('StarNotary', accounts => { 

    beforeEach(async function() { 
        this.contract = await StarNotary.new({from: accounts[0]})
    })

    const name = 'awesome star'
    const story = 'awesome story'
    const ra = 'ra_12.34'
    const dec = 'dec_23.45'
    const mag = 'mag_45.67'
    // const cent = 'cent_34.67'

    const starId = 1

    const user1 = accounts[1]
    const user2 = accounts[2]

    const randomMaliciousUser = accounts[3]

    describe('can create a star', () => { 
        it('can create a star and get its props', async function () { 
            
            await this.contract.createStar(name, story, ra, dec, mag, /*cent,*/ starId, {from: accounts[0]})

            res = await this.contract.tokenIdToStarInfo(starId);
            assert.equal(res[0], name);
            assert.equal(res[1], story);
            assert.equal(res[2], ra);
            assert.equal(res[3], dec);
            assert.equal(res[4], mag);
        })
    })

    describe('buying and selling stars', () => { 
        
        let starPrice = web3.toWei(.01, "ether")

        beforeEach(async function () { 
            await this.contract.createStar(name, story, ra, dec, mag, /*cent,*/ starId, {from: user1})    
        })

        it('user1 can put up their star for sale', async function () { 
            assert.equal(await this.contract.ownerOf(starId), user1)
            await this.contract.putStarUpForSale(starId, starPrice, {from: user1})
            
            assert.equal(await this.contract.starsForSale(starId), starPrice)
        })

        describe('user2 can buy a star that was put up for sale', () => { 
            beforeEach(async function () { 
                await this.contract.putStarUpForSale(starId, starPrice, {from: user1})
            })

            it('user2 is the owner of the star after they buy it', async function() { 
                await this.contract.buyStar(starId, {from: user2, value: starPrice, gasPrice: 0})
                assert.equal(await this.contract.ownerOf(starId), user2)
            })

            it('user2 ether balance changed correctly', async function () { 
                let overpaidAmount = web3.toWei(.05, 'ether')
                const balanceBeforeTransaction = web3.eth.getBalance(user2)
                await this.contract.buyStar(starId, {from: user2, value: overpaidAmount, gasPrice: 0})
                const balanceAfterTransaction = web3.eth.getBalance(user2)

                assert.equal(balanceBeforeTransaction.sub(balanceAfterTransaction), starPrice)
            })
        })
    })

    describe('check if star exists', () => { 

        beforeEach(async function () { 
            await this.contract.createStar(name, story, ra, dec, mag, /*cent,*/ starId, {from: user1})    
        })

        it('check if star exists checkIfStarExist()', async function () { 
            
            assert.equal(await this.contract.checkIfStarExist(ra, dec, mag/*, cent*/), true);
        })
    })
})