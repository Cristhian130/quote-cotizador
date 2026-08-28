import '../domain/transfer_suggestion.dart';
import '../domain/transfers_repository.dart';
import 'transfers_remote_data_source.dart';

class TransfersRepositoryImpl implements TransfersRepository {
  final TransfersRemoteDataSource remote;

  TransfersRepositoryImpl({required this.remote});

  @override
  Future<TransferSuggestionsResult> findSuggestionsByCity(
    CityTransferRequest request,
  ) => remote.findSuggestionsByCity(request);

  @override
  Future<TransferSuggestionsResult> findSuggestions(TransferRequest request) =>
      remote.findSuggestions(request);

  @override
  Future<TransferPreview> preview(TransferRequest request) =>
      remote.preview(request);
}
