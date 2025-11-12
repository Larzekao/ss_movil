import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

/// Estados del reconocimiento de voz
enum VoiceStatus { idle, checking, ready, listening, error }

/// Estado del controlador de voz
class VoiceState {
  final VoiceStatus status;
  final String? errorMessage;
  final String partialText;
  final String finalText;
  final bool isAvailable;
  final List<stt.LocaleName> availableLocales;

  const VoiceState({
    this.status = VoiceStatus.idle,
    this.errorMessage,
    this.partialText = '',
    this.finalText = '',
    this.isAvailable = false,
    this.availableLocales = const [],
  });

  VoiceState copyWith({
    VoiceStatus? status,
    String? errorMessage,
    String? partialText,
    String? finalText,
    bool? isAvailable,
    List<stt.LocaleName>? availableLocales,
  }) {
    return VoiceState(
      status: status ?? this.status,
      errorMessage: errorMessage,
      partialText: partialText ?? this.partialText,
      finalText: finalText ?? this.finalText,
      isAvailable: isAvailable ?? this.isAvailable,
      availableLocales: availableLocales ?? this.availableLocales,
    );
  }

  bool get isListening => status == VoiceStatus.listening;
  bool get isReady => status == VoiceStatus.ready;
  bool get hasError => status == VoiceStatus.error;
}

/// Controlador de reconocimiento de voz
class VoiceController extends StateNotifier<VoiceState> {
  final stt.SpeechToText _speech = stt.SpeechToText();
  String? _selectedLocaleId;

  VoiceController() : super(const VoiceState());

  /// Inicializa el reconocimiento de voz y verifica permisos
  Future<void> init() async {
    if (state.isAvailable && state.isReady) {
      // Ya está inicializado
      return;
    }

    state = state.copyWith(status: VoiceStatus.checking);

    try {
      // Verificar y solicitar permisos
      final permissionStatus = await Permission.microphone.status;

      if (permissionStatus.isDenied) {
        final result = await Permission.microphone.request();
        if (result.isDenied || result.isPermanentlyDenied) {
          state = state.copyWith(
            status: VoiceStatus.error,
            errorMessage: 'Activa el micrófono en Ajustes para dictar',
          );
          return;
        }
      }

      // Inicializar speech to text
      final available = await _speech.initialize(
        onError: (error) {
          state = state.copyWith(
            status: VoiceStatus.error,
            errorMessage: 'Error de reconocimiento: ${error.errorMsg}',
          );
        },
        onStatus: (status) {
          if (status == 'done' && state.isListening) {
            // Escucha finalizada
            state = state.copyWith(status: VoiceStatus.ready);
          }
        },
      );

      if (!available) {
        state = state.copyWith(
          status: VoiceStatus.error,
          errorMessage:
              'Reconocimiento de voz no disponible en este dispositivo',
        );
        return;
      }

      // Obtener locales disponibles
      final locales = await _speech.locales();

      // Buscar locale español Bolivia
      String? selectedLocale;

      // Prioridad 1: es_BO
      final esBoLocale = locales.firstWhere(
        (l) => l.localeId.toLowerCase().startsWith('es_bo'),
        orElse: () => stt.LocaleName('', ''),
      );

      if (esBoLocale.localeId.isNotEmpty) {
        selectedLocale = esBoLocale.localeId;
      } else {
        // Prioridad 2: Cualquier es_*
        final esLocale = locales.firstWhere(
          (l) => l.localeId.toLowerCase().startsWith('es_'),
          orElse: () => stt.LocaleName('', ''),
        );

        if (esLocale.localeId.isNotEmpty) {
          selectedLocale = esLocale.localeId;
        } else {
          // Prioridad 3: System locale
          final systemLocale = await _speech.systemLocale();
          selectedLocale = systemLocale?.localeId;
        }
      }

      _selectedLocaleId = selectedLocale;

      state = state.copyWith(
        status: VoiceStatus.ready,
        isAvailable: true,
        availableLocales: locales,
      );
    } catch (e) {
      state = state.copyWith(
        status: VoiceStatus.error,
        errorMessage: 'Error al inicializar: $e',
      );
    }
  }

  /// Inicia la escucha con resultados parciales
  Future<void> startListening({String? localeId}) async {
    if (!state.isAvailable) {
      await init();
      if (!state.isAvailable) return;
    }

    if (state.isListening) {
      return; // Ya está escuchando
    }

    // Limpiar textos anteriores
    state = state.copyWith(
      status: VoiceStatus.listening,
      partialText: '',
      finalText: '',
      errorMessage: null,
    );

    final localeToUse = localeId ?? _selectedLocaleId;

    try {
      await _speech.listen(
        onResult: (result) {
          if (result.finalResult) {
            // Resultado final
            state = state.copyWith(
              finalText: result.recognizedWords,
              partialText: '',
              status: VoiceStatus.ready,
            );
          } else {
            // Resultado parcial
            state = state.copyWith(partialText: result.recognizedWords);
          }
        },
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 3),
        partialResults: true,
        onSoundLevelChange: null,
        cancelOnError: true,
        listenMode: stt.ListenMode.confirmation,
        localeId: localeToUse,
      );
    } catch (e) {
      state = state.copyWith(
        status: VoiceStatus.error,
        errorMessage: 'Error al iniciar escucha: $e',
      );
    }
  }

  /// Detiene la escucha
  Future<void> stop() async {
    if (!state.isListening) return;

    await _speech.stop();
    state = state.copyWith(status: VoiceStatus.ready, partialText: '');
  }

  /// Cancela la escucha
  Future<void> cancel() async {
    if (!state.isListening) return;

    await _speech.cancel();
    state = state.copyWith(
      status: VoiceStatus.ready,
      partialText: '',
      finalText: '',
    );
  }

  /// Limpia el estado de error
  void clearError() {
    if (state.hasError) {
      state = state.copyWith(status: VoiceStatus.ready, errorMessage: null);
    }
  }

  @override
  void dispose() {
    _speech.stop();
    super.dispose();
  }
}

/// Provider del controlador de voz
final voiceControllerProvider =
    StateNotifierProvider<VoiceController, VoiceState>((ref) {
      return VoiceController();
    });
