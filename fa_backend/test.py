def test(a, b, c):
    print("Hello World!")
    print(a + b + c)


j = (
    test,
    (
        1,
        2,
        3,
    ),
)

j[0](*j[1])
