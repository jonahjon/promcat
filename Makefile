pull:
	helm pull stable/grafana --untar -d .

up:
	chmod +x up.sh && ./up.sh

down:
	chmod +x up.sh && ./up.sh -d true
