IMG=baseten/deepgemm:base
CONTAINER_NAME=deep_gemm
.PHONY: format docker_build clean

docker_build:
	docker build -t $(IMG) -f docker/Dockerfile .

docker_run:
	docker rm -f $(CONTAINER_NAME) || true
	docker run -d \
		-v $(realpath ../):/workspace \
		-it --ipc=host --shm-size 32g \
		--entrypoint bash \
		--gpus all \
		--name $(CONTAINER_NAME) \
		$(IMG) \
		-c 'sleep infinity'

docker_push:
	docker push $(IMG)

install_dep:
	uv sync
	uv pip install dist/blite_tracing-0.1.0-py3-none-any.whl
	uv pip install dist/flash_attn-2.8.3-cp312-cp312-linux_x86_64.whl
	uv pip install apache-tvm-ffi --prerelease=allow
# 	uv pip install dist/b10_kernel-0.1.4-py312-none-linux_x86_64.whl
# 	uv pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu130
# 	uv pip install dist/flash_attn-2.8.3+cu12torch2.9-cp312-cp312-linux_x86_64.whl

clean:
	rm -rf *.mp4 && rm -rf *.json && rm -rf *.json.gz

zip_outputs:
	zip -r demo_outputs.zip ./*.mp4 ./*.json ./*.json.gz
