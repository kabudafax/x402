# AI 策略实现文档

## 概述

实现了基于技术指标的简单交易策略，可以在链上执行基本的交易信号生成。

## 实现内容

### 1. TechnicalIndicators 库

位置: `contracts/src/strategies/TechnicalIndicators.sol`

**功能**:
- ✅ **SMA (Simple Moving Average)** - 简单移动平均线
- ✅ **RSI (Relative Strength Index)** - 相对强弱指标
- ✅ **Golden Cross Detection** - 金叉检测
- ✅ **Death Cross Detection** - 死叉检测
- ✅ **Overbought/Oversold Detection** - 超买/超卖检测

**使用示例**:
```solidity
uint256[] memory prices = [100, 105, 110, 108, 112];
uint256 sma = TechnicalIndicators.calculateSMA(prices, 5);
uint256 rsi = TechnicalIndicators.calculateRSI(prices, 14);
```

### 2. SimpleStrategy 库

位置: `contracts/src/strategies/SimpleStrategy.sol`

**功能**:
- ✅ **Signal Generation** - 生成交易信号（买入/卖出/持有）
- ✅ **Confidence Calculation** - 计算信号置信度
- ✅ **Multi-Indicator Analysis** - 多指标综合分析

**策略逻辑**:
1. 计算短期和长期移动平均线
2. 检测金叉/死叉
3. 计算 RSI
4. 检测超买/超卖
5. 综合判断生成信号

**信号规则**:
- **BUY**: 金叉 + 超卖，或短期 MA > 长期 MA + 超卖
- **SELL**: 死叉 + 超买，或短期 MA < 长期 MA + 超买
- **HOLD**: 其他情况

### 3. StrategyService 合约

位置: `contracts/src/strategies/StrategyService.sol`

**功能**:
- ✅ 继承 Service 合约
- ✅ 实现策略服务逻辑
- ✅ 可配置策略参数
- ✅ 返回交易信号和置信度

**使用方式**:
```solidity
// 输入: (uint256[] prices, StrategyParams params)
// 输出: (Signal signal, uint256 confidence, uint256 timestamp)
```

## 策略参数

默认参数：
- **短期 MA**: 5 日
- **长期 MA**: 20 日
- **RSI 周期**: 14 日
- **超买阈值**: 70
- **超卖阈值**: 30

## 扩展建议

### 未来改进

1. **更多技术指标**
   - MACD
   - Bollinger Bands
   - Stochastic Oscillator

2. **更复杂的策略**
   - 多时间框架分析
   - 趋势跟踪策略
   - 均值回归策略

3. **链下计算**
   - 复杂策略可以在链下计算
   - 链上验证和执行

4. **机器学习集成**
   - 使用预言机获取 AI 模型预测
   - 结合链上指标和链下 AI

## 使用示例

### 在 Agent 中使用策略服务

```solidity
// 1. 获取价格数据
uint256[] memory prices = [100, 105, 110, 108, 112, 115, 113];

// 2. 调用策略服务
bytes memory input = abi.encode(prices, defaultParams);
bytes memory result = agent.callService(
    strategyServiceAddress,
    paymentRequest,
    abi.encodeWithSignature("executeService(bytes32,bytes)", paymentId, input)
);

// 3. 解析结果
(Signal signal, uint256 confidence, uint256 timestamp) = 
    abi.decode(result, (Signal, uint256, uint256));

// 4. 根据信号执行交易
if (signal == Signal.BUY && confidence > 6000) {
    agent.buyToken(...);
}
```

## 注意事项

1. **Gas 成本**: 链上计算技术指标会消耗 gas，建议：
   - 限制价格数组长度
   - 缓存计算结果
   - 考虑链下计算

2. **数据来源**: 需要可靠的价格数据源：
   - 使用链上价格预言机
   - 或通过数据服务获取

3. **策略风险**: 
   - 简单策略可能不够准确
   - 建议结合风险管理
   - 不要投入过多资金

---

**实现状态**: ✅ 基础策略已实现，可扩展

