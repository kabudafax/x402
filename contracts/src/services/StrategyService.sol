// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Service} from "../Service.sol";
import {SimpleStrategy} from "../strategies/SimpleStrategy.sol";

/**
 * @title StrategyService
 * @notice Extended Service contract with strategy implementation
 * @dev This service provides trading signals based on technical analysis
 */
contract StrategyService is Service {
    using SimpleStrategy for uint256[];

    // Default strategy parameters
    SimpleStrategy.StrategyParams public defaultParams;

    constructor(
        address _x402Payment,
        string memory _name,
        string memory _description,
        uint256 _price,
        address _paymentToken,
        PricingModel _pricingModel,
        address _provider
    ) Service(
        _x402Payment,
        _name,
        _description,
        ServiceType.STRATEGY,
        _price,
        _paymentToken,
        _pricingModel,
        _provider
    ) {
        // Default strategy parameters
        defaultParams = SimpleStrategy.StrategyParams({
            shortMAPeriod: 5,
            longMAPeriod: 20,
            rsPeriod: 14,
            overboughtThreshold: 7000, // 70
            oversoldThreshold: 3000     // 30
        });
    }

    /**
     * @notice Update strategy parameters
     * @param shortMAPeriod Short MA period
     * @param longMAPeriod Long MA period
     * @param rsPeriod RSI period
     * @param overboughtThreshold Overbought threshold
     * @param oversoldThreshold Oversold threshold
     */
    function updateStrategyParams(
        uint256 shortMAPeriod,
        uint256 longMAPeriod,
        uint256 rsPeriod,
        uint256 overboughtThreshold,
        uint256 oversoldThreshold
    ) external onlyProvider {
        defaultParams = SimpleStrategy.StrategyParams({
            shortMAPeriod: shortMAPeriod,
            longMAPeriod: longMAPeriod,
            rsPeriod: rsPeriod,
            overboughtThreshold: overboughtThreshold,
            oversoldThreshold: oversoldThreshold
        });
    }

    /**
     * @notice Execute strategy service logic
     * @param serviceType Service type (should be STRATEGY)
     * @param input Encoded price data and parameters
     * @return output Encoded trading signal
     */
    function _executeServiceLogic(
        ServiceType serviceType,
        bytes calldata input
    ) internal view override returns (bytes memory output) {
        require(serviceType == ServiceType.STRATEGY, "Invalid service type");

        // Decode input: (uint256[] prices, StrategyParams params)
        (uint256[] memory prices, SimpleStrategy.StrategyParams memory params) = 
            abi.decode(input, (uint256[], SimpleStrategy.StrategyParams));

        // Use default params if not provided
        if (params.shortMAPeriod == 0) {
            params = defaultParams;
        }

        // Generate signal
        (SimpleStrategy.Signal signal, uint256 confidence) = 
            SimpleStrategy.generateSignal(prices, params);

        // Encode output: (Signal signal, uint256 confidence, uint256 timestamp)
        output = abi.encode(signal, confidence, block.timestamp);
    }
}

