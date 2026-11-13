// Wadah hasil operasi jaringan: hanya bisa Success atau Failure.
// sealed agar switch di Controller dicek lengkap oleh compiler.
sealed class Result<T, E> {
  const Result();

  bool get isSuccess => this is Success<T, E>;
  bool get isFailure => this is Failure<T, E>;
}

class Success<T, E> extends Result<T, E> {
  final T data;
  const Success(this.data);
}

class Failure<T, E> extends Result<T, E> {
  final E error;
  const Failure(this.error);
}
