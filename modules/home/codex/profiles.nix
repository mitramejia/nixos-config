{
  ollamaLaunch = {
    model_provider = "ollama-launch";
    forced_login_method = "api";

    model_providers.ollama-launch = {
      name = "Ollama";
      base_url = "http://127.0.0.1:11434/v1/";
      wire_api = "responses";
    };
  };

  gptOss = {
    model_provider = "ollama-launch";
    model = "gpt-oss";
  };
}
