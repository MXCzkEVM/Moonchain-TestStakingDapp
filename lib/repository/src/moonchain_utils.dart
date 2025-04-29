class MoonchainUtils {
  static String chainIdToName(int aId) {
    switch (aId) {
      case 18686:
        return 'Moonchain Mainnet';
      case 5167004:
        return 'Moonchain Geneva';
      case 421614:
        return 'Arbitrum Sepolia';
      case 42161:
        return 'Arbitrum One';
      default:
        return 'Unsupported.';
    }
  }
}
