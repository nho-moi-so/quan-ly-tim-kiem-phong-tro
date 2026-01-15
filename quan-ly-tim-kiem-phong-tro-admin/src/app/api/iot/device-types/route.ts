import { IoTDeviceInDepartmentRepository } from "@/repositories/iotDeviceInDepartmentRepository";
import { IoTDeviceRepository } from "@/repositories/iotDeviceRepository";
import { NextResponse } from "next/server";
import { z } from "zod";

const CreateSchema = z.object({
  id: z.string().min(1, "id required").optional(),
  name: z.string().min(1, "name required"),
  description: z.string().optional(),
});

export async function GET() {
  try {
    const data = await IoTDeviceRepository.getAll();
    const allConnectedDevices = await IoTDeviceInDepartmentRepository.getAll();
    
    // Add connection count to each device type
    const dataWithConnections = data.map((device) => ({
      ...device,
      connectionCount: allConnectedDevices.filter((conn) => conn.DeviceID === device.Id).length,
    }));
    
    return NextResponse.json({ status: "success", data: dataWithConnections });
  } catch (err: unknown) {
    return NextResponse.json(
      { status: "fail", message: err instanceof Error ? err.message : "Unknown error" },
      { status: 500 }
    );
  }
}

export async function POST(request: Request) {
  try {
    const json = await request.json();
    const { id, name, description } = CreateSchema.parse(json);

    if (id) {
      const existed = await IoTDeviceRepository.getById(id);
      if (existed) {
        return NextResponse.json(
          { status: "fail", message: "ID đã tồn tại" },
          { status: 400 }
        );
      }
    }

    const created = id
      ? await IoTDeviceRepository.createWithId(id, { Name: name, Description: description })
      : await IoTDeviceRepository.create({ Name: name, Description: description });
    return NextResponse.json({ status: "success", data: created });
  } catch (err: unknown) {
    if (err instanceof z.ZodError) {
      return NextResponse.json({ status: "fail", message: err.issues[0].message }, { status: 400 });
    }
    return NextResponse.json(
      { status: "fail", message: err instanceof Error ? err.message : "Unknown error" },
      { status: 500 }
    );
  }
}
