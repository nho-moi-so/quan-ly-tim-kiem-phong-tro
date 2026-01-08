import { IoTDeviceRepository } from "@/repositories/iotDeviceRepository";
import { NextResponse } from "next/server";
import { z } from "zod";

const UpdateSchema = z.object({
  name: z.string().min(1, "name required"),
  description: z.string().optional(),
});

export async function GET(_: Request, { params }: { params: { id: string } }) {
  try {
    const id = params.id;
    if (!id) {
      return NextResponse.json(
        { status: "fail", message: "Missing id" },
        { status: 400 }
      );
    }

    const device = await IoTDeviceRepository.getById(id);
    return NextResponse.json({ status: "success", exists: !!device, data: device });
  } catch (err: unknown) {
    return NextResponse.json(
      { status: "fail", message: err instanceof Error ? err.message : "Unknown error" },
      { status: 500 }
    );
  }
}

export async function PUT(request: Request, { params }: { params: { id: string } }) {
  try {
    const id = params.id;
    if (!id) {
      return NextResponse.json(
        { status: "fail", message: "Missing id" },
        { status: 400 }
      );
    }

    const json = await request.json();
    const { name, description } = UpdateSchema.parse(json);

    const updated = await IoTDeviceRepository.update(id, { Name: name, Description: description });
    return NextResponse.json({ status: "success", data: updated });
  } catch (err: unknown) {
    if (err instanceof z.ZodError) {
      return NextResponse.json({ status: "fail", message: err.errors[0].message }, { status: 400 });
    }
    return NextResponse.json(
      { status: "fail", message: err instanceof Error ? err.message : "Unknown error" },
      { status: 500 }
    );
  }
}

export async function DELETE(_: Request, { params }: { params: { id: string } }) {
  try {
    const id = params.id;
    if (!id) {
      return NextResponse.json(
        { status: "fail", message: "Missing id" },
        { status: 400 }
      );
    }

    await IoTDeviceRepository.delete(id);
    return NextResponse.json({ status: "success", message: "Device type deleted" });
  } catch (err: unknown) {
    return NextResponse.json(
      { status: "fail", message: err instanceof Error ? err.message : "Unknown error" },
      { status: 500 }
    );
  }
}
