// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {TechnicalIndicators} from "./TechnicalIndicators.sol";

/**
 * @title SimpleStrategy
 * @notice Simple trading strategy using technical indicators
 * @dev This is a basic implementation - can be extended for more complex strategies
 */
library SimpleStrategy {
    using TechnicalIndicators for uint256[];

    enum Signal {
        BUY,
        SELL,
        HOLD
    }

    struct StrategyParams {
        uint256 shortMAPeriod;      // Short MA period (e.g., 5)
        uint256 longMAPeriod;        // Long MA period (e.g., 20)
        uint256 rsPeriod;            // RSI period (e.g., 14)
        uint256 overboughtThreshold; // RSI overbought (e.g., 7000 = 70)
        uint256 oversoldThreshold;  // RSI oversold (e.g., 3000 = 30)
    }

    /**
     * @notice Generate trading signal based on technical indicators
     * @param prices Array of historical prices
     * @param params Strategy parameters
     * @return signal Trading signal (BUY, SELL, or HOLD)
     * @return confidence Confidence level (0-10000, scaled by 100)
     */
    function generateSignal(
        uint256[] memory prices,
        StrategyParams memory params
    ) internal pure returns (Signal signal, uint256 confidence) {
        require(prices.length >= params.longMAPeriod, "Insufficient price data");

        // Calculate moving averages
        uint256 shortMA = TechnicalIndicators.calculateSMA(
            prices,
            params.shortMAPeriod
        );
        uint256 longMA = TechnicalIndicators.calculateSMA(
            prices,
            params.longMAPeriod
        );

        // Calculate previous MAs for cross detection
        uint256[] memory prevPrices = new uint256[](prices.length - 1);
        for (uint256 i = 0; i < prevPrices.length; i++) {
            prevPrices[i] = prices[i];
        }
        
        uint256 prevShortMA = prevPrices.length >= params.shortMAPeriod
            ? TechnicalIndicators.calculateSMA(prevPrices, params.shortMAPeriod)
            : shortMA;
        uint256 prevLongMA = prevPrices.length >= params.longMAPeriod
            ? TechnicalIndicators.calculateSMA(prevPrices, params.longMAPeriod)
            : longMA;

        // Calculate RSI
        uint256 rsi = TechnicalIndicators.calculateRSI(prices, params.rsPeriod);

        // Generate signal based on indicators
        bool goldenCross = TechnicalIndicators.detectGoldenCross(
            shortMA,
            longMA,
            prevShortMA,
            prevLongMA
        );
        bool deathCross = TechnicalIndicators.detectDeathCross(
            shortMA,
            longMA,
            prevShortMA,
            prevLongMA
        );
        bool overbought = TechnicalIndicators.isOverbought(
            rsi,
            params.overboughtThreshold
        );
        bool oversold = TechnicalIndicators.isOversold(
            rsi,
            params.oversoldThreshold
        );

        // Signal logic
        if (goldenCross && oversold) {
            signal = Signal.BUY;
            confidence = 8000; // 80% confidence
        } else if (deathCross && overbought) {
            signal = Signal.SELL;
            confidence = 8000; // 80% confidence
        } else if (shortMA > longMA && oversold) {
            signal = Signal.BUY;
            confidence = 6000; // 60% confidence
        } else if (shortMA < longMA && overbought) {
            signal = Signal.SELL;
            confidence = 6000; // 60% confidence
        } else if (goldenCross) {
            signal = Signal.BUY;
            confidence = 5000; // 50% confidence
        } else if (deathCross) {
            signal = Signal.SELL;
            confidence = 5000; // 50% confidence
        } else {
            signal = Signal.HOLD;
            confidence = 3000; // 30% confidence (uncertain)
        }
    }
}

