.PHONY: train serve test docker-build docker-run k8s-deploy

train:
	python training/train.py --config app/config.yaml

export:
	python training/model_export.py --model models/best_model.pt

serve:
	uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload

test:
	pytest tests/

docker-build:
	docker build -t isl-ml-service:latest -f deployment/Dockerfile .

docker-run:
	docker run -p 8000:8000 --gpus all isl-ml-service:latest

k8s-deploy:
	kubectl apply -f deployment/k8s/

benchmark:
	python scripts/benchmark_inference.py