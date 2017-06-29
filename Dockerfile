FROM python:2.7

RUN pip install platformio \
    && platformio platforms install atmelavr --with-package framework-arduinoavr
