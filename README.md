# NonceGeek Leaf Contract

## **Getting started**

1. Initialize the aptos configuration, if you don't already have it
```shell
# create leaf addr
aptos init --profile leaf

# create minter1 addr
aptos init --profile minter1

# create minter2 addr
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

## **NFT Sample**

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

## **MintEvent Sample**

```shell
[
  {
    "version": "335819765",
    "guid": {
      "creation_number": "5",
      "account_address": "0x64a2981664ece2680e8ddae825729c693d0f9bfabaa40c19b1660091966a747"
    },
    "sequence_number": "0",
    "type": "0x62398bae6a6ab490143e374a006ea3b1fcafe655fcca5adfcd30d5a0a315c38::LEAF::MintEvent",
    "data": {
      "counter": "1",
      "owner_address": "0xe698622471b41a92e13ae893ae4ff88b20c528f6da2bedcb24d74646bf972dc3"
    }
  }
]
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