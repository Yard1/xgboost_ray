TUNE=1
LEGACY=0

for i in "$@"
do
echo "$i"
case "$i" in
    --no-tune)
    TUNE=0
    ;;
    --legacy)
    LEGACY=1
    ;;
    *)
    echo "unknown arg, $i"
    exit 1
    ;;
esac
done

pushd xgboost_ray/tests || exit 1
echo "============="
echo "Running tests"
echo "============="
python -m pytest -vv -s --log-cli-level=DEBUG --durations=0 -x test_colocation.py
python -m pytest -v --durations=0 -x test_matrix.py
python -m pytest -v --durations=0 -x test_data_source.py
python -m pytest -v --durations=0 -x test_xgboost_api.py
python -m pytest -v --durations=0 -x test_fault_tolerance.py
python -m pytest -v --durations=0 -x test_end_to_end.py
if [ "$LEGACY" = "1" ]; then
  python -m pytest -v --durations=0 -x test_sklearn.py::XGBoostRaySklearnTest::test_binary_classification
  python -m pytest -v --durations=0 -x test_sklearn.py::XGBoostRaySklearnTest::test_multiclass_classification
  python -m pytest -v --durations=0 -x test_sklearn.py::XGBoostRaySklearnTest::test_boston_housing_regression
  python -m pytest -v --durations=0 -x test_sklearn.py::XGBoostRaySklearnTest::test_sklearn_api
  python -m pytest -v --durations=0 -x test_sklearn.py::XGBoostRaySklearnTest::test_sklearn_clone
else
  python -m pytest -v --durations=0 -x test_sklearn.py
fi

if [ "$TUNE" = "1" ]; then
  python -m pytest -v --durations=0 -x test_tune.py
else
  echo "skipping tune tests"
fi

echo "running smoke test on benchmark_cpu_gpu.py" && python release/benchmark_cpu_gpu.py 2 10 20 --smoke-test
popd || exit 1