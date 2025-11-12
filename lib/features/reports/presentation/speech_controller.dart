import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

/// Estados posibles del reconocimiento de voz
enum SpeechState { idle, listening, error }

/// Modelo de estado para el reconocimiento de voz
class SpeechRecognitionState {
  final SpeechState state;
  final String transcribedText;
  final String? errorMessage;
  final bool isAvailable;
  final List<String> availableLocales;

  const SpeechRecognitionState({
    required this.state,
    this.transcribedText = '',
    this.errorMessage,
    this.isAvailable = false,
    this.availableLocales = const [],
  });

  SpeechRecognitionState copyWith({
    SpeechState? state,
    String? transcribedText,
    String? errorMessage,
    bool? isAvailable,
    List<String>? availableLocales,
  }) {
    return SpeechRecognitionState(
      state: state ?? this.state,
      transcribedText: transcribedText ?? this.transcribedText,
      errorMessage: errorMessage,
      isAvailable: isAvailable ?? this.isAvailable,
      availableLocales: availableLocales ?? this.availableLocales,
    );
  }
}

/// Controller para manejar el reconocimiento de voz
class SpeechController extends StateNotifier<SpeechRecognitionState> {
  final stt.SpeechToText _speech = stt.SpeechToText();
  String _currentLocale = 'es_BO'; // Idioma por defecto: Español Bolivia

  SpeechController()
    : super(const SpeechRecognitionState(state: SpeechState.idle)) {
    _initialize();
  }

  /// Inicializar el servicio de reconocimiento de voz
  Future<void> _initialize() async {
    try {
      // Verificar permisos
      final status = await Permission.microphone.status;
      if (!status.isGranted) {
        final result = await Permission.microphone.request();
        if (!result.isGranted) {
          state = state.copyWith(
            state: SpeechState.error,
            errorMessage: 'Permiso de micrófono denegado',
            isAvailable: false,
          );
          return;
        }
      }

      // Inicializar speech_to_text
      final available = await _speech.initialize(
        onError: (error) {
          state = state.copyWith(
            state: SpeechState.error,
            errorMessage: 'Error: ${error.errorMsg}',
          );
        },
        onStatus: (status) {
          if (status == 'done' || status == 'notListening') {
            if (state.state == SpeechState.listening) {
              state = state.copyWith(state: SpeechState.idle);
            }
          }
        },
      );

      if (available) {
        // Obtener idiomas disponibles
        final locales = await _speech.locales();
        final localeIds = locales.map((l) => l.localeId).toList();

        // Verificar si está disponible es-BO, sino usar es-ES
        if (localeIds.contains('es_BO')) {
          _currentLocale = 'es_BO';
        } else if (localeIds.contains('es_ES')) {
          _currentLocale = 'es_ES';
        } else if (localeIds.any((l) => l.startsWith('es'))) {
          _currentLocale = localeIds.firstWhere((l) => l.startsWith('es'));
        }

        state = state.copyWith(isAvailable: true, availableLocales: localeIds);
      } else {
        state = state.copyWith(
          state: SpeechState.error,
          errorMessage:
              'Reconocimiento de voz no disponible en este dispositivo',
          isAvailable: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        state: SpeechState.error,
        errorMessage: 'Error al inicializar: $e',
        isAvailable: false,
      );
    }
  }

  /// Iniciar escucha y transcripción
  Future<void> startListening() async {
    if (!state.isAvailable) {
      state = state.copyWith(
        state: SpeechState.error,
        errorMessage: 'Servicio de voz no disponible',
      );
      return;
    }

    if (_speech.isListening) {
      await stopListening();
      return;
    }

    try {
      state = state.copyWith(state: SpeechState.listening, errorMessage: null);

      await _speech.listen(
        onResult: (result) {
          state = state.copyWith(transcribedText: result.recognizedWords);
        },
        localeId: _currentLocale,
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 3),
        listenOptions: stt.SpeechListenOptions(
          partialResults: true,
          cancelOnError: true,
          listenMode: stt.ListenMode.confirmation,
        ),
      );
    } catch (e) {
      state = state.copyWith(
        state: SpeechState.error,
        errorMessage: 'Error al iniciar escucha: $e',
      );
    }
  }

  /// Detener escucha
  Future<void> stopListening() async {
    if (_speech.isListening) {
      await _speech.stop();
      state = state.copyWith(state: SpeechState.idle);
    }
  }

  /// Limpiar texto transcrito
  void clearText() {
    state = state.copyWith(transcribedText: '', errorMessage: null);
  }

  /// Cambiar idioma de reconocimiento
  void setLocale(String localeId) {
    if (state.availableLocales.contains(localeId)) {
      _currentLocale = localeId;
    }
  }

  @override
  void dispose() {
    _speech.cancel();
    super.dispose();
  }
}

/// Provider del SpeechController
final speechControllerProvider =
    StateNotifierProvider<SpeechController, SpeechRecognitionState>((ref) {
      return SpeechController();
    });
