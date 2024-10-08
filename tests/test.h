#pragma once
#include <FastSIMD/DispatchClass.h>
#include <cstddef>
#include <map>
#include <functional>
#include <string_view>
#include <vector>
#include <string>

constexpr size_t kTestBytes = 512 / 8;

struct TestResult
{
    uint8_t returnCount;
};

using TestFunction = size_t ( void*, size_t, int32_t*, float* );
using InputsFunction = std::string ( size_t, int32_t*, float* );

struct TestData
{
    enum class ReturnType
    {
        boolean, f32, i32
    };
    
    FastSIMD::FeatureSet featureSet;
    bool relaxed;
    ReturnType returnType;
    float relaxedAccuracy = 0;
    std::function<TestFunction> testFunc;
    std::function<InputsFunction> inputsFunc;
};

using TestCollection = std::vector<std::pair<std::string_view, TestData>>;

template<size_t RegisterBytes, bool Relaxed>
class TestFastSIMD
{
public:
    virtual ~TestFastSIMD() = default;

    virtual TestCollection RegisterTests() = 0;
};
