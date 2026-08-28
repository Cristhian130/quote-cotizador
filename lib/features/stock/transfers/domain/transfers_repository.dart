import 'transfer_suggestion.dart';

abstract class TransfersRepository {
  Future<TransferSuggestionsResult> findSuggestionsByCity(
    CityTransferRequest request,
  );
  Future<TransferSuggestionsResult> findSuggestions(TransferRequest request);
  Future<TransferPreview> preview(TransferRequest request);
}
