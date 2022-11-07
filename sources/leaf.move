module myself::LEAF {

    use aptos_framework::aptos_coin::AptosCoin;
    use aptos_framework::coin;
    use aptos_framework::account;

    use std::signer;
    use std::string::{Self, String};
    use std::vector;

    use aptos_token::token;
    use aptos_std::event::{Self, EventHandle};

    #[test_only]
    use aptos_std::debug::{print};

    struct MintEvent has store, drop {
        owner_address: address,
        counter: u64,
    }

    struct MintData has store, key {
        counter: u64,
        mint_price: u64,
        mint_events: EventHandle<MintEvent>,
        minting_enabled: bool,
        signer_cap: account::SignerCapability,
    }

    const EGIVEN_MESSAGE_NOT_MATCH_EXPECTED_MESSAGE: u64 = 1;
    const EMESSAGE_SIGNATURE_INVALID: u64 = 2;
    const ENOT_AUTHORIZED: u64 = 3;
    const EHAS_ALREADY_CLAIMED_MINT: u64 = 4;
    const EMINTING_NOT_ENABLED: u64 = 5;

    const MAX_U64: u64 = 18446744073709551615;
    const COLLECTION_NAME: vector<u8> = b"NonceGeek Leaf";
    const TOKEN_NAME: vector<u8> = b"Leaf";
    const TOKEN_URL_PREFIX: vector<u8> = b"https://localhost:4000/nft_images/noncegeek-leaf/";

    public entry fun initial_module_script(sender: &signer, price: u64) {
        if (exists<MintData>(signer::address_of(sender))) {
            return
        };

        let (resource, signer_cap) = account::create_resource_account(sender, vector::empty());

        // Set up NFT collection
        let collection_name = string::utf8(COLLECTION_NAME);
        let description = string::utf8(b"Hello World");
        let collection_uri = string::utf8(b"https://localhost:4000/offers/noncegeek-leaf");
        let maximum_supply = MAX_U64;
        let mutate_setting = vector<bool>[ false, false, false ];

        token::create_collection(&resource, collection_name, description, collection_uri, maximum_supply, mutate_setting);

        move_to(sender, MintData { 
            counter: 1, 
            mint_price: price,
            mint_events: account::new_event_handle<MintEvent>(&resource),
            minting_enabled: true, 
            signer_cap 
        });
    }

    fun get_resource_signer(): signer acquires MintData {
        account::create_signer_with_capability(&borrow_global<MintData>(@myself).signer_cap)
    }

    fun u64_to_string(value: u64): string::String {
        if (value == 0) {
            return string::utf8(b"0")
        };
        let buffer = vector::empty<u8>();
        while (value != 0) {
            vector::push_back(&mut buffer, ((48 + value % 10) as u8));
            value = value / 10;
        };
        vector::reverse(&mut buffer);
        string::utf8(buffer)
    }

    fun mint<CoinType>(sender: &signer) acquires MintData {
        let sender_addr = signer::address_of(sender);

        let resource = get_resource_signer();

        let cm = borrow_global_mut<MintData>(@myself);

        let count_str = u64_to_string(cm.counter);

        // Set up the NFT
        let collection_name = string::utf8(COLLECTION_NAME);
        let tokendata_name = string::utf8(TOKEN_NAME);
        string::append_utf8(&mut tokendata_name, b": ");
        string::append(&mut tokendata_name, count_str);

        let nft_maximum: u64 = 1;
        let description = string::utf8(b"Hello World!");
        let token_uri: string::String = string::utf8(TOKEN_URL_PREFIX);

        string::append(&mut token_uri, count_str);

        let royalty_payee_address: address = @myself;
        let royalty_points_denominator: u64 = 0;
        let royalty_points_numerator: u64 = 0;

        let token_mutate_config = token::create_token_mutability_config(&vector<bool>[ false, true, false, false, true ]);

        let token_data_id = token::create_tokendata(
            &resource,
            collection_name,
            tokendata_name,
            description,
            nft_maximum,
            token_uri,
            royalty_payee_address,
            royalty_points_denominator,
            royalty_points_numerator,
            token_mutate_config,
            vector::empty<String>(),
            vector::empty<vector<u8>>(),
            vector::empty<String>(),
        );

        let token_id = token::mint_token(&resource, token_data_id, 1);

        coin::transfer<CoinType>(sender, @myself, cm.mint_price);

        token::initialize_token_store(sender);

        token::opt_in_direct_transfer(sender, true);
        token::transfer(&resource, token_id, sender_addr, 1);

        event::emit_event(&mut cm.mint_events, MintEvent { owner_address: sender_addr, counter: cm.counter });

        cm.counter = cm.counter + 1;
    }

    public entry fun mint_script(sender: &signer) acquires MintData {
        let cm = borrow_global<MintData>(@myself);
        assert!(cm.minting_enabled, EMINTING_NOT_ENABLED);
        mint<AptosCoin>(sender);
    }

    #[test(aptos_framework = @0x1, sender = @myself)]
    public fun test_initial_module(aptos_framework: &signer, sender: &signer) acquires MintData {
        // create amount
        account::create_account_for_test(signer::address_of(aptos_framework));
        account::create_account_for_test(signer::address_of(sender));

        initial_module_script(sender, 300);

        let sender_addr = signer::address_of(sender);

        let minter = borrow_global_mut<MintData>(sender_addr);
        print<u64>(&minter.counter);

        assert!(minter.counter == 1, 0);
        assert!(minter.mint_price == 300, 0);
    }

    #[test(aptos_framework = @0x1, myself = @myself, sender = @0xAE)]
    public fun test_mint(aptos_framework: &signer, myself: &signer, sender: &signer) acquires MintData {
        // create amount
        account::create_account_for_test(signer::address_of(aptos_framework));
        account::create_account_for_test(signer::address_of(myself));
        account::create_account_for_test(signer::address_of(sender));

        initial_module_script(myself, 300);

        coin::register<coin::FakeMoney>(myself);
        coin::create_fake_money(aptos_framework, sender, 300);
        coin::transfer<coin::FakeMoney>(aptos_framework, signer::address_of(sender), 300);

        mint<coin::FakeMoney>(sender);

        let myself_addr = signer::address_of(myself);
        let minter = borrow_global_mut<MintData>(myself_addr);

        // print(&minter);

        assert!(minter.counter == 2, 0);
        assert!(coin::balance<coin::FakeMoney>(signer::address_of(myself)) == 300, 1);
        assert!(coin::balance<coin::FakeMoney>(signer::address_of(sender)) == 0, 1);
    }
}