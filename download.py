"""
Go download the "models" folder structure directly from the comfyui source
"""
import requests
from pathlib import Path


def recursive_download(url):
	"""
	Crawls the github api url
	Recursively explores all the folders within, and download all the files at correct paths
	:param url: github api url. ex: https://api.github.com/repos/oobabooga/text-generation-webui/contents/user_data
	:raises: requests.exceptions.RequestException: There was an error while accessing the api (ex: rate limit exceeded)
	"""
	print(f'Recursive download: {url}')
	query = requests.get(url)
	if query.status_code == 200:
		result = query.json()

		for item in result:
			path = Path(item['path'])

			if item['type'] == 'file':
				if not path.is_file():
					download_url = item['download_url']
					print(f'Downloading file {path}: {download_url}')

					file_dl = requests.get(download_url)
					if file_dl.status_code == 200:
						with open(path, 'wb') as file:
							file.write(file_dl.content)
					else:
						raise requests.exceptions.RequestException(f'Request failed with status code {query.status_code}\n{query.json()}')

			else:
				print(f'folder "{path}"')
				path.mkdir(parents=True, exist_ok=True)
				recursive_download(item['_links']['self'])

	else:
		raise requests.exceptions.RequestException(f'Request failed with status code {query.status_code}\n{query.json()}')


if __name__ == '__main__':
	recursive_download('https://api.github.com/repos/oobabooga/text-generation-webui/contents/user_data')
