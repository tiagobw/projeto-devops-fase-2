import { Injectable } from '@nestjs/common';
import { CreateTodoDto } from './dto/create-todo.dto';
import { UpdateTodoDto } from './dto/update-todo.dto';

@Injectable()
export class TodosService {
  create(createTodoDto: CreateTodoDto) {
    return `This action adds a new todo\nThe received dto is ${JSON.stringify(createTodoDto)}`;
  }

  findAll() {
    return `This action returns all todos [With Docker]`;
  }

  findOne(id: number) {
    return `This action returns a #${id} todo`;
  }

  update(id: number, updateTodoDto: UpdateTodoDto) {
    return `This action updates a #${id} todo\nThe received dto is ${JSON.stringify(updateTodoDto)}`;
  }

  remove(id: number) {
    return `This action removes a #${id} todo`;
  }
}
