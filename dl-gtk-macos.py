import requests
import os
import zipfile
import shutil

GITLAB_URL = "https://gitlab.gnome.org/"
PERSONAL_ACCESS_TOKEN = os.environ.get("GITLAB_KEY")
PROJECT_ID = "665"  # The GNOME/GTK project
JOB_NAME = "macos: [macosarm]"
ARTIFACT_NAME = "artifacts.zip"
SAVE_PATH = "./"
TARGET_FILE = "_build/gtk/GdkMacos-4.0.gir"

PIPELINES_URL = f"{GITLAB_URL}/api/v4/projects/{PROJECT_ID}/pipelines"
HEADERS = {"Authorization": f"Bearer {PERSONAL_ACCESS_TOKEN}"}


def http_get(url, *, expect_json=True, **kwargs):
    response = requests.get(url, **kwargs)

    content_type = response.headers.get("Content-Type", "")
    print(f"\nGET {url}")
    print(f"Status: {response.status_code}")
    print(f"Content-Type: {content_type}")

    preview = response.text[:500]
    if preview:
        print("Body preview:")
        print(preview)
    else:
        print("Body preview: <empty>")

    response.raise_for_status()

    if expect_json:
        if "application/json" not in content_type:
            raise ValueError(f"Expected JSON response, got '{content_type}'")
        return response.json()

    return response


def get_job_with_artifact(pipeline_id, job_name):
    url = f"{GITLAB_URL}/api/v4/projects/{PROJECT_ID}/pipelines/{pipeline_id}/jobs"

    try:
        jobs = http_get(url, headers=HEADERS)

        for job in jobs:
            if job["name"] == job_name:
                return job

        print(
            f"No job with artifact '{ARTIFACT_NAME}' found in pipeline {pipeline_id}."
        )
        return None

    except (requests.exceptions.RequestException, ValueError) as e:
        print(f"Error fetching jobs: {e}")
        return None


def download_artifact(job_id, save_path):
    url = f"{GITLAB_URL}/api/v4/projects/{PROJECT_ID}/jobs/{job_id}/artifacts"

    try:
        response = http_get(
            url,
            headers=HEADERS,
            stream=True,
            expect_json=False,
        )

        artifact_path = os.path.join(save_path, ARTIFACT_NAME)
        with open(artifact_path, "wb") as file:
            for chunk in response.iter_content(chunk_size=1024):
                if chunk:
                    file.write(chunk)

        print(f"Artifact saved to: {artifact_path}")
        return artifact_path

    except requests.exceptions.RequestException as e:
        print(f"Error downloading artifact: {e}")
        return None


def extract_and_copy_file(artifact_path, target_file, destination_path):
    try:
        temp_dir = os.path.join(os.path.dirname(artifact_path), "temp_extracted")
        os.makedirs(temp_dir, exist_ok=True)

        with zipfile.ZipFile(artifact_path, "r") as zip_ref:
            zip_ref.extractall(temp_dir)

        target_file_path = os.path.join(temp_dir, target_file)
        if os.path.exists(target_file_path):
            shutil.copy(target_file_path, destination_path)
            print(f"Copied '{target_file_path}' to '{destination_path}'.")
        else:
            print(f"File '{target_file}' not found in the extracted contents.")

        shutil.rmtree(temp_dir)
        os.remove(artifact_path)
        print("Temporary files cleaned up.")

    except Exception as e:
        print(f"Error extracting or copying file: {e}")


def main():
    try:
        pipelines = http_get(
            PIPELINES_URL,
            headers=HEADERS,
            params={
                "order_by": "updated_at",
                "sort": "desc",
            },
        )

        if not pipelines:
            exit("No pipelines found.")

        for pipeline in pipelines:
            job = get_job_with_artifact(pipeline["id"], JOB_NAME)
            if not job or job["status"] != "success":
                continue

            print(f"Job '{job['name']}' succeeded (Job ID: {job['id']}).")

            artifact_path = download_artifact(job["id"], SAVE_PATH)
            if artifact_path:
                extract_and_copy_file(artifact_path, TARGET_FILE, "./")
            break

    except (requests.exceptions.RequestException, ValueError) as e:
        exit(f"Error fetching pipelines: {e}")


if __name__ == "__main__":
    main()
