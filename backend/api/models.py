from django.db import models

class AccountSign(models.Model):
    username = models.CharField(max_length=100)
    email = models.CharField(max_length=200)
    password = models.CharField(max_length=500)
    create_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return self.username