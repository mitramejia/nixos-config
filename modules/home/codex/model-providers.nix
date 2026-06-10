{
  mlx = {
    name = "MLX LM";
    base_url = "http://localhost:8888/v1";
  };

  ollama-launch = {
    name = "Ollama";
    base_url = "http://127.0.0.1:11434/v1/";
    wire_api = "responses";
  };

  omlx = {
    name = "oMLX";
    base_url = "http://127.0.0.1:8000/v1";
    env_key = "OMLX_API_KEY";
  };
}
