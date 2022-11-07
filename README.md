# NonceGeek Leaf Contract

## **Getting started**

1. Initialize the aptos configuration, if you don't already have it
```shell
# create marketplace addr
aptos init --profile leaf

# create minter 1 addr
aptos init --profile minter1

# create minter 2 addr
aptos init --profile minter2
```

2. Fund with faucet
```shell
# faucet
aptos account fund-with-faucet --account leaf
aptos account fund-with-faucet --account minter1
aptos account fund-with-faucet --account minter2
```

3. Compile contract
```shell
aptos move compile --named-addresses myself=leaf
```

4. Test Contract
```shell
# test
aptos move test --named-addresses myself=leaf
```

5. Publish Contract to DevNet/TestNet
```shell
# publish
aptos move publish --included-artifacts none --named-addresses myself=leaf --profile=leaf
```

6. Publisher call contract `initial_module_script` when publish succeed
```shell
aptos move run --function-id 'leaf::LEAF::initial_module_script' --args 'u64:300' --profile=leaf
```

7. Minter call contract fun `mint_script`
```shell
aptos move run --function-id 'leaf::LEAF::mint_script' --profile=minter1

aptos move run --function-id 'leaf::LEAF::mint_script' --profile=minter2
```

## **NFT Detail**

```shell
{
    "token_id": {
      "property_version": 0,
      "token_data_id": {
        "collection": "NonceGeek Leaf",
        "creator": "0x64a2981664ece2680e8ddae825729c693d0f9bfabaa40c19b1660091966a747",
        "name": "Leaf: 1"
      }
    },
    "uri": "https://localhost:4000/nft_images/aptos-zero/1"
}
```

## **Features**

- [x] initial module
- [x] mint
- [x] test_initial_module
- [x] test_mint

## **Contributing**

Bug report or pull request are welcome.

## **Make a pull request**

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

Please write unit test with your code if necessary.

## **License**

web3 is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).