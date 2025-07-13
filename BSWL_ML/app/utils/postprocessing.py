def postprocess(model_output, lang="en"):
    # Example: map model output to text
    return {"text": model_output["text"], "confidence": model_output["confidence"]}
