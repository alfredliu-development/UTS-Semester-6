from django.contrib.auth.hashers import make_password, check_password
from django.http import JsonResponse
from django.http import HttpResponse
from django.shortcuts import render
from django.views.decorators.csrf import csrf_exempt
import json

from api.models import AccountSign


def get_name(request):
    return HttpResponse("Shizuku-chan")

@csrf_exempt
def sign_up(request):
    if request.method == "POST":
        data = json.loads(request.body)

        if AccountSign.objects.filter(email=data['email']).exists():
            return JsonResponse({"error": "The e-mail is already registered"}, status=400)

        hashed_pw = make_password(data["password"])
        user = AccountSign.objects.create(
            username=data["username"],
            email=data["email"],
            password=hashed_pw
        )

        return JsonResponse({"message" : "this data is success"}, status=201)

    return JsonResponse({"error" : "the method must POST"}, status=405)

@csrf_exempt
def sign_in(request):
    if request.method == "POST":
        data = json.loads(request.body)

        try:
            user = AccountSign.objects.get(email=data["email"], password=data["password"])

            if check_password(data["password"], user.password):
                return JsonResponse({"message" : "this password is success"}, status=200)

            return JsonResponse({"message" : "this password and email is wrong"}, status=401)

        except AccountSign.DoesNotExist:
            return JsonResponse({"message" : "this data is fail"}, status=404)

    return JsonResponse({"error" : "the method must POST"}, status=405)