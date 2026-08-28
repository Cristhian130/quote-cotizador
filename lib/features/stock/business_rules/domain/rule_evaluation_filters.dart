class RuleEvaluationFilters {
  final String companyId;
  final String city;
  final int pageSize;
  final double minimumStock;
  final int minimumDaysWithoutSale;

  const RuleEvaluationFilters({
    this.companyId = '',
    this.city = '',
    this.pageSize = 100,
    required this.minimumStock,
    required this.minimumDaysWithoutSale,
  });
}
