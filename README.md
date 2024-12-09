# Tech1000 repo

## Initial setup

* Created project in github and checked out
* Ran
    * forge init --force
    * forge install OpenZeppelin/openzeppelin-contracts
    * forge install foundry-rs/forge-std
* Deleted counters junk
* Added Tech1000 contract / test / scripts

## Dev setup

```
git clone https://github.com/tactical-retreat/tech1000.git
cd tech1000
forge test
# should pass
```

## Testing

```
forge test
```

## Deployment

Deploying - see instructions in `script/DeployTech1000.s.sol`.

Whitelisting - see instructions in `script/WhitelistScript.s.sol`.