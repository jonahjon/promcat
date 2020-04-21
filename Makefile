pull:
	helm pull stable/grafana --untar -d .

pipenv-install:
	pipenv graph || pipenv install

dashboards: pipenv-install
	pipenv run python config_render.py > config_all.yaml;