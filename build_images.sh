#!/bin/bash -e

# Usage helper
usage() {
  echo "Usage:"
  echo "  -h, --help                Display this help message"
  echo "  -i, --image image         Docker image to build"
  echo "  -d, --dir dir             Directory for build context"
  echo
  echo "Optional:"
  echo "  -f, --file Dockerfile     Name of the Dockerfile (defaults to 'Dockerfile')"
  echo "  -t, --tag tag             Tags for docker image (ie. latest; repeat to add more tags)"
  echo "  -s, --semantic version    Generate docker tags for version based on semantic convention (ie 1.2.3)"
  echo "  -l, --label label         Labels to pass to docker build (ie label=value; optional, repeat to add more labels)"
  echo
  echo "Arguments after '--' will be pass to the docker build step. This can be used to pass build args,"
  echo "                            invalidate the cache, etc."
}

# Default variables
image=
dir=
file=
declare -a tags
semantic=
declare -a labels
build_opts=

# Parse arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help) usage; exit 0;;
    -i|--image) image=$2; shift; shift;;
    -d|--dir) dir=$2; shift; shift;;
    -f|--file) file=$2; shift; shift;;
    -t|--tag) tags=("${tags[@]}" $2); shift; shift;;
    -s|--semantic) semantic=$2; shift; shift;;
    -l|--labels) labels=("${labels[@]}" $2); shift; shift;;

    --) shift; build_opts="$@"; break;;
    *) echo "Invalid Option: $1"
       usage; exit 1;;
  esac
done

# Check image argument
if [ -z "$image" ]; then
  echo "Docker image is missing"
  usage; exit 1
fi

# Check dir argument
if [ -z "$dir" ]; then
  echo "Directory for build context is missing"
  usage; exit 1
else
  if [ ! -d "$dir" ]; then
    echo "Cannot find directory \"$dir\" for build context"
    exit 1
  fi
fi

# Check file argument
filearg=
if [ -n "$file" ]; then
  filearg="-f $dir/$file"
  if [ ! -e "$dir/$file" ]; then
    echo "Dockerfile '$dir/$file' is missing"
    exit 1
  fi
fi

# Set default tag
if [ ${#tags} -lt 1 ]; then
  tags=(latest)
  echo "Warning: Docker image will be tag with \"latest\""
fi

# Generate semantic tags
if [ -n "$semantic" ]; then
  echo "Adding tags for semantic version \"$semantic\""
  tags=("${tags[@]}" $semantic)
  tags=("${tags[@]}" ${semantic%.*})
  tags=("${tags[@]}" ${semantic%%.*})
fi

# Generate labels for build
labels_text=""
if [ ${#labels} -ge 1 ]; then
  for label in "${labels[@]}"; do
    labels_text="$labels_text --label $label"
  done
fi

echo "Building and push image '$image' from directory '$dir'"
docker build $labels_text -t $image:build $filearg $build_opts $dir

# Push all tags
for tag in "${tags[@]}"; do
  echo "Tagging and pushing image with tag \"$tag\""
  docker tag $image:build $image:$tag
  docker push $image:$tag
done
