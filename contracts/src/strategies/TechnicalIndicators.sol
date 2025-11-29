// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title TechnicalIndicators
 * @notice Simple technical indicator calculations for trading strategies
 * @dev These are simplified implementations for on-chain use
 */
library TechnicalIndicators {
    /**
     * @notice Calculate Simple Moving Average (SMA)
     * @param prices Array of prices
     * @param period Period for SMA calculation
     * @return sma Simple moving average
     */
    function calculateSMA(
        uint256[] memory prices,
        uint256 period
    ) internal pure returns (uint256 sma) {
        require(prices.length >= period, "Insufficient data");
        require(period > 0, "Invalid period");
        
        uint256 sum = 0;
        uint256 startIndex = prices.length - period;
        
        for (uint256 i = startIndex; i < prices.length; i++) {
            sum += prices[i];
        }
        
        sma = sum / period;
    }

    /**
     * @notice Calculate Relative Strength Index (RSI)
     * @param prices Array of prices
     * @param period Period for RSI calculation (typically 14)
     * @return rsi RSI value (0-100, scaled by 100)
     */
    function calculateRSI(
        uint256[] memory prices,
        uint256 period
    ) internal pure returns (uint256 rsi) {
        require(prices.length > period, "Insufficient data");
        require(period > 0, "Invalid period");
        
        uint256 gains = 0;
        uint256 losses = 0;
        
        // Calculate average gain and loss
        for (uint256 i = prices.length - period; i < prices.length - 1; i++) {
            int256 change = int256(prices[i + 1]) - int256(prices[i]);
            if (change > 0) {
                gains += uint256(change);
            } else {
                losses += uint256(-change);
            }
        }
        
        uint256 avgGain = gains / (period - 1);
        uint256 avgLoss = losses / (period - 1);
        
        if (avgLoss == 0) {
            return 10000; // RSI = 100 (scaled by 100)
        }
        
        uint256 rs = (avgGain * 10000) / avgLoss;
        rsi = 10000 - (10000 / (1 + rs));
    }

    /**
     * @notice Detect golden cross (bullish signal)
     * @param shortMA Short-term moving average
     * @param longMA Long-term moving average
     * @param prevShortMA Previous short-term MA
     * @param prevLongMA Previous long-term MA
     * @return isGoldenCross True if golden cross detected
     */
    function detectGoldenCross(
        uint256 shortMA,
        uint256 longMA,
        uint256 prevShortMA,
        uint256 prevLongMA
    ) internal pure returns (bool isGoldenCross) {
        // Golden cross: short MA crosses above long MA
        isGoldenCross = (shortMA > longMA) && (prevShortMA <= prevLongMA);
    }

    /**
     * @notice Detect death cross (bearish signal)
     * @param shortMA Short-term moving average
     * @param longMA Long-term moving average
     * @param prevShortMA Previous short-term MA
     * @param prevLongMA Previous long-term MA
     * @return isDeathCross True if death cross detected
     */
    function detectDeathCross(
        uint256 shortMA,
        uint256 longMA,
        uint256 prevShortMA,
        uint256 prevLongMA
    ) internal pure returns (bool isDeathCross) {
        // Death cross: short MA crosses below long MA
        isDeathCross = (shortMA < longMA) && (prevShortMA >= prevLongMA);
    }

    /**
     * @notice Check if RSI indicates overbought condition
     * @param rsi RSI value (scaled by 100)
     * @param threshold Overbought threshold (typically 7000 = 70)
     * @return isOverbought True if overbought
     */
    function isOverbought(
        uint256 rsi,
        uint256 threshold
    ) internal pure returns (bool isOverbought) {
        isOverbought = rsi >= threshold;
    }

    /**
     * @notice Check if RSI indicates oversold condition
     * @param rsi RSI value (scaled by 100)
     * @param threshold Oversold threshold (typically 3000 = 30)
     * @return isOversold True if oversold
     */
    function isOversold(
        uint256 rsi,
        uint256 threshold
    ) internal pure returns (bool isOversold) {
        isOversold = rsi <= threshold;
    }
}

