// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@chainlink/contracts/src/v0.8/ChainlinkClient.sol";

/**
 * Request testnet LINK and ETH here: https://faucets.chain.link/
 * Find information on LINK Token Contracts and get the latest ETH and LINK faucets here: https://docs.chain.link/docs/link-token-contracts/
 */

/**
 * THIS IS AN EXAMPLE CONTRACT WHICH USES HARDCODED VALUES FOR CLARITY.
 * PLEASE DO NOT USE THIS CODE IN PRODUCTION.
 */
contract FetchVotes is ChainlinkClient {
    using Chainlink for Chainlink.Request;

    string public blockNumber;

    bytes32 private jobId;
    uint256 private fee;

    constructor() {
        setChainlinkToken(0x326C977E6efc84E512bB9C30f76E30c160eD06FB);
        setChainlinkOracle(0x40193c8518BB267228Fc409a613bDbD8eC5a97b3);
        jobId = "7d80a6386ef543a3abb52817f6707e3b";
        fee = 0.1 * 10**18; // (Varies by network and job)
    }

    /**
     * Create a Chainlink request to retrieve API response, find the target
     * data, then multiply by 1000000000000000000 (to remove decimal places from data).
     */
    function requestVotes() public returns (bytes32 requestId) {
        Chainlink.Request memory request = buildChainlinkRequest(
            jobId,
            address(this),
            this.fulfill.selector
        );

        // Set the URL to perform the GET request on
        request.add(
            "get",
            "https://gist.githubusercontent.com/Bhakti087/ffd53a8408f10e2c228bb4a21c71f503/raw/41104a11012267457a1a723f22b46e6a3088e5bb/bytes-example.json"
        );

        //   "data": {
        //     "proposal": {
        //       "scores": [
        //         3,
        //         1,
        //         0
        //       ],
        //       "quorum": 0
        //     }
        //   }
        // }
        // request.add("path", "data,proposal,scores,1"); // Chainlink nodes prior to 1.0.0 support this format
        request.add("path", "blockNumber"); // Chainlink nodes 1.0.0 and later support this format

        // Sends the request
        return sendChainlinkRequest(request, fee);
    }

    /**
     * Receive the response in the form of uint256
     */
    function fulfill(bytes32 _requestId, string memory _votes)
        public
        recordChainlinkFulfillment(_requestId)
    {
        blockNumber = _votes;
    }
}
