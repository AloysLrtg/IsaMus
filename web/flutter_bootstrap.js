{{flutter_js}}
{{flutter_build_config}}

// The release build targets JavaScript + CanvasKit (do not build with --wasm).
_flutter.loader.load({
  config: { renderer: "canvaskit" },
});
